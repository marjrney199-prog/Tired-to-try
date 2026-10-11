const $=(q,root=document)=>root.querySelector(q);
const $$=(q,root=document)=>Array.from(root.querySelectorAll(q));
const main=$('#mainContent'), toastEl=$('#toast'), modalLayer=$('#modalLayer');
const STORAGE_KEY='escola_english_progress_v1';
let DATA=null;
let view='home';
let quizState=null;
let deferredInstall=null;
let toastTimer=null;
let state={verbQuery:'',verbCategory:'all',verbPage:1,wordQuery:'',wordPos:'all',wordFilter:'all',wordPage:1,bankCategory:'all',openDialogue:0};
let progress=loadProgress();

function loadProgress(){
  try{
    const saved=JSON.parse(localStorage.getItem(STORAGE_KEY)||'{}');
    return Object.assign({xp:0,streak:0,lastActivity:'',activityDays:[],completedLessons:[],learnedWords:[],savedWords:[],quizStats:{},sessions:0,correctAnswers:0},saved);
  }catch(e){return {xp:0,streak:0,lastActivity:'',activityDays:[],completedLessons:[],learnedWords:[],savedWords:[],quizStats:{},sessions:0,correctAnswers:0};}
}
function saveProgress(){localStorage.setItem(STORAGE_KEY,JSON.stringify(progress));updateChrome();}
function esc(value=''){return String(value).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
function todayKey(date=new Date()){return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;}
function dayDiff(a,b){return Math.round((new Date(b+'T00:00:00')-new Date(a+'T00:00:00'))/86400000);}
function recordActivity(points=0){
  const today=todayKey();
  if(progress.lastActivity!==today){
    if(progress.lastActivity&&dayDiff(progress.lastActivity,today)===1) progress.streak=(progress.streak||0)+1;
    else if(progress.lastActivity!==today) progress.streak=1;
    progress.lastActivity=today;
  }
  progress.activityDays=Array.from(new Set([...(progress.activityDays||[]),today])).slice(-90);
  progress.sessions=(progress.sessions||0)+1;
  progress.xp=(progress.xp||0)+points;
  saveProgress();
}
function showToast(msg){toastEl.textContent=msg;toastEl.classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>toastEl.classList.remove('show'),2300);}
function speak(text,accent='en-US'){
  if(!('speechSynthesis' in window)){showToast('A leitura áudio não está disponível neste navegador.');return;}
  speechSynthesis.cancel();
  const u=new SpeechSynthesisUtterance(String(text).replace(/[“”]/g,''));
  u.lang=accent;
  const voices=speechSynthesis.getVoices();
  const preferred=voices.find(v=>v.lang===accent)||voices.find(v=>v.lang.startsWith('en-'));
  if(preferred)u.voice=preferred;
  u.rate=.88;u.pitch=1;
  speechSynthesis.speak(u);
}
function updateChrome(){
  $('#xpCount').textContent=`${progress.xp||0} XP`;
  $('#streakCount').textContent=`${progress.streak||0} dias`;
}
function setActiveNavigation(){
  $$('.nav-item,.side-link').forEach(b=>b.classList.toggle('active',b.dataset.view===view));
}
function go(next,extra){
  view=next;quizState=null;
  if(next==='lesson') state.currentLesson=extra;
  if(next==='quiz') quizState=extra;
  setActiveNavigation();
  $('#sidebar').classList.remove('open');
  render();
  window.scrollTo({top:0,behavior:'smooth'});
}
function button(label,action,extra='',cls='button button-primary'){
  return `<button class="${cls}" data-action="${action}" ${extra}>${label}</button>`;
}
function heading(eyebrow,title,subtitle='',right=''){
  return `<div class="page-header"><div><div class="eyebrow">${esc(eyebrow)}</div><h1 class="page-title">${esc(title)}</h1>${subtitle?`<p class="page-subtitle">${esc(subtitle)}</p>`:''}</div>${right}</div>`;
}
function panelTitle(title,subtitle='',right=''){
  return `<div class="card-title-row"><div><h2 class="card-title">${esc(title)}</h2>${subtitle?`<p class="card-subtitle">${esc(subtitle)}</p>`:''}</div>${right}</div>`;
}
function formatLevel(){
  const n=(progress.completedLessons||[]).length;
  if(n<2)return 'A0 · Primeiros passos';
  if(n<5)return 'A1 · Iniciante';
  if(n<9)return 'A2 · Elementar';
  return 'B1+ · Em progresso';
}
function nextLesson(){return DATA.tenses.find(t=>!(progress.completedLessons||[]).includes(t.key))||DATA.tenses[0];}
function weeklyDots(){
  const days=['D','S','T','Q','Q','S','S'];
  const dates=[];for(let i=6;i>=0;i--){const d=new Date();d.setDate(d.getDate()-i);dates.push(d);}
  return dates.map((d,i)=>{const key=todayKey(d),done=(progress.activityDays||[]).includes(key),today=i===6;return `<div class="day-dot ${done?'done':''} ${today?'today':''}"><i>${done?'✓':days[d.getDay()]}</i><span>${['Dom','Seg','Ter','Qua','Qui','Sex','Sáb'][d.getDay()]}</span></div>`;}).join('');
}
function renderHome(){
  const nxt=nextLesson();
  const completed=(progress.completedLessons||[]).length;
  const learned=(progress.learnedWords||[]).length;
  const quizDone=Object.values(progress.quizStats||{}).reduce((a,b)=>a+(b.attempts||0),0);
  const pct=Math.round(completed/DATA.tenses.length*100), circumference=2*Math.PI*32, offset=circumference-(pct/100)*circumference;
  main.innerHTML=`<div class="page">
    <section class="hero">
      <div class="hero-content"><div class="eyebrow">ESCOLA DO CONHECIMENTO · ${esc(formatLevel())}</div><h1>O teu próximo passo<br>em inglês começa aqui.</h1><p>Aprende com lições curtas, exemplos práticos, pronúncia guiada e exercícios com explicações. Um percurso do básico à comunicação profissional.</p><div class="hero-actions">${button('Continuar a aprender <span>→</span>','open-next','','button button-primary')}${button('Fazer uma prática rápida','start-random','','button button-secondary')}</div></div>
      <div class="hero-statbox"><div class="progress-ring"><svg viewBox="0 0 76 76"><circle class="track" cx="38" cy="38" r="32"/><circle class="value" cx="38" cy="38" r="32" stroke-dasharray="${circumference}" stroke-dashoffset="${offset}"/></svg><div class="ring-number">${pct}%</div></div><div><strong>${completed} de 12 lições</strong><small>concluídas na trilha</small></div></div>
    </section>
    <section class="stats-grid">
      <div class="stat-card"><div class="stat-icon gold">✦</div><div><strong>${progress.xp||0}</strong><small>Pontos de estudo (XP)</small></div></div>
      <div class="stat-card"><div class="stat-icon">🔥</div><div><strong>${progress.streak||0}</strong><small>Dias de sequência</small></div></div>
      <div class="stat-card"><div class="stat-icon">Aa</div><div><strong>${learned}</strong><small>Palavras aprendidas</small></div></div>
      <div class="stat-card"><div class="stat-icon">✓</div><div><strong>${quizDone}</strong><small>Práticas realizadas</small></div></div>
    </section>
    <div class="dashboard-grid">
      <section class="card continue-card"><div>${panelTitle('Continuar trilha','Uma unidade de cada vez.',`<span class="tag gold">${completed<12?'PRÓXIMA LIÇÃO':'REVISÃO'}</span>`)}</div><div class="continue-body"><div class="lesson-badge">${String(DATA.tenses.indexOf(nxt)+1).padStart(2,'0')}</div><div class="continue-text"><strong>${esc(nxt.name)}</strong><small>${esc(nxt.explain.slice(0,115))}…</small><div class="continue-progress"><i style="width:${progress.completedLessons?.includes(nxt.key)?100:0}%"></i></div></div>${button('Abrir','open-next','','button button-outline button-small')}</div></section>
      <section class="card weekly-card">${panelTitle('Ritmo semanal','Pequenos passos, todos os dias.') }<div class="week-row">${weeklyDots()}</div><div class="week-note">🔥 <strong>${progress.streak||0} dias</strong> de sequência. Uma sessão curta hoje mantém o hábito.</div></section>
    </div>
    <h2 class="section-heading">Escolhe o que queres praticar</h2>
    <div class="quick-grid">
      <article class="card quick-card" data-action="navigate" data-view="lessons"><div class="quick-icon">▤</div><strong>Gramática em contexto</strong><small>12 tempos verbais, estruturas e exemplos.</small></article>
      <article class="card quick-card" data-action="navigate" data-view="verbs"><div class="quick-icon">V</div><strong>Super dicionário</strong><small>236 verbos com formas e exemplos bilingues.</small></article>
      <article class="card quick-card" data-action="navigate" data-view="vocabulary"><div class="quick-icon">Ab</div><strong>1.000 palavras</strong><small>Procura, ouve e guarda vocabulário.</small></article>
      <article class="card quick-card" data-action="navigate" data-view="practice"><div class="quick-icon">✓</div><strong>Treino interactivo</strong><small>Exercícios com correcção e explicações.</small></article>
    </div>
    <div class="dashboard-grid" style="margin-top:20px">
      <section class="card card-pad">${panelTitle('Percurso de 16 semanas','Uma rota sugerida — adapta-a ao teu ritmo.')}<div class="roadmap-list" style="margin-top:10px">${DATA.roadmap.map(r=>`<div class="roadmap-item"><div class="roadmap-week">${esc(r.week)}</div><div><strong>${esc(r.title)}</strong><p>${esc(r.detail)}</p></div></div>`).join('')}</div><button class="text-link" data-action="navigate" data-view="lessons" style="margin-top:7px">Ver as lições →</button></section>
      <section class="card card-pad">${panelTitle('Dica de aprendizagem','Recuperação activa')}<div class="callout blue" style="margin-top:16px">Antes de consultares a resposta, tenta recordar a regra ou palavra. O esforço de recuperação fortalece a memória.</div><p class="small text-muted">Revisa hoje, amanhã e novamente ao fim de 3, 7 e 14 dias.</p><div class="small-label" style="margin-top:20px">Frase oficial</div><p class="serif" style="font-style:italic;color:var(--navy);margin:6px 0 0">“${esc(DATA.quote)}”</p><small class="text-muted">— ${esc(DATA.author)}</small></section>
    </div><div class="footer-note">${esc(DATA.appName)} · ${esc(DATA.school)} · A pronúncia é aproximada; usa áudio e prática real.</div>
  </div>`;
}
function renderLessons(){
  const done=progress.completedLessons||[];
  main.innerHTML=`<div class="page">${heading('TRILHA DE APRENDIZAGEM','Lições de gramática','Do presente ao futuro: compreende a forma, o uso e a diferença entre tempos semelhantes.')}<div class="callout blue">Começa por uma explicação curta, compara os exemplos e termina com um conjunto de exercícios. Todas as unidades estão abertas — segue a ordem sugerida ou escolhe uma necessidade específica.</div><div class="grid-3">${DATA.tenses.map((t,i)=>{const isDone=done.includes(t.key);return `<article class="card lesson-card" data-action="open-lesson" data-id="${esc(t.key)}"><div class="lesson-card-top"><span class="lesson-number">${String(i+1).padStart(2,'0')}</span><span class="tag ${isDone?'green':'gold'}">${isDone?'CONCLUÍDA':i<4?'FUNDAMENTOS':'INTERMÉDIO+'}</span></div><h3>${esc(t.name)}</h3><p>${esc(t.explain)}</p><div class="mini-progress"><i style="width:${isDone?100:0}%"></i></div></article>`;}).join('')}</div><div class="footer-note">As 12 lições correspondem às formas de tempo/aspecto tradicionalmente ensinadas.</div></div>`;
}
function renderLesson(key){
  const t=DATA.tenses.find(x=>x.key===key)||DATA.tenses[0];
  const idx=DATA.tenses.indexOf(t)+1, done=(progress.completedLessons||[]).includes(t.key);
  const uses=t.uses.map(x=>`<li>${esc(x)}</li>`).join('');
  const examples=t.examples.map(x=>`<div class="example-row"><div><div class="example-en">${esc(x[0])}</div><div class="pron-line">${esc(x[1])}</div></div><div class="example-pt">${esc(x[2])}</div></div>`).join('');
  const quiz=DATA.quizzes.find(q=>q.id==='tense_'+t.key);
  main.innerHTML=`<div class="page lesson-detail"><button class="back-link" data-action="navigate" data-view="lessons">← Voltar às lições</button>${heading(`LIÇÃO ${String(idx).padStart(2,'0')} · TEMPOS VERBAIS`,t.name,'Entende a estrutura, identifica o contexto e usa a forma em frases reais.',`<span class="tag ${done?'green':'gold'}">${done?'CONCLUÍDA':'EM CURSO'}</span>`)}
    <div class="lesson-intro-card"><div class="small-label">IDEIA CENTRAL</div><p>${esc(t.explain)}</p></div>
    <div class="formula-box"><div class="small-label">FÓRMULA PRINCIPAL</div><strong>${esc(t.formula)}</strong></div>
    <h2 class="section-heading">Quando usar</h2><ul class="bullet-list">${uses}</ul>
    <div class="callout blue"><strong>Marcadores frequentes:</strong> ${esc(t.markers)}</div>
    <h2 class="section-heading">Regras de construção</h2><p class="text-muted small">${esc(t.rule)}</p>
    <h2 class="section-heading">Exemplos com pronúncia e tradução</h2><div class="example-grid">${examples}</div>
    <div class="callout red"><strong>Erro comum:</strong> ${esc(t.error)}</div><div class="callout"><strong>Compare:</strong> ${esc(t.contrast)}</div>
    <div class="lesson-footer-actions">${button(done?'Lição concluída ✓':'Marcar como concluída','complete-lesson',`data-id="${esc(t.key)}"`,'button button-primary')}${button('Praticar este tempo →','open-quiz',`data-id="${esc(quiz?.id||'') }"`,'button button-outline')}</div>
    <div class="footer-note">Faz também uma frase tua com esta estrutura. A gramática fica mais sólida quando a ligas à tua rotina.</div>
  </div>`;
}
function renderVerbs(){
  const query=state.verbQuery.trim().toLowerCase();
  const categories=['all',...Array.from(new Set(DATA.verbs.map(v=>v.category))).sort()];
  const filtered=DATA.verbs.filter(v=>{
    const text=[v.word,v.translation,v.exampleEn,v.examplePt,v.category].join(' ').toLowerCase();
    return (!query||text.includes(query))&&(state.verbCategory==='all'||v.category===state.verbCategory);
  });
  const size=24,total=Math.max(1,Math.ceil(filtered.length/size));state.verbPage=Math.min(state.verbPage,total);
  const shown=filtered.slice((state.verbPage-1)*size,state.verbPage*size);
  main.innerHTML=`<div class="page">${heading('DICIONÁRIO DE VERBOS','236 verbos essenciais','Formas verbais, tradução, pronúncia aproximada e exemplos completos. Clica numa entrada para ver os detalhes.')}<div class="toolbar"><label class="search-box"><span>⌕</span><input id="verbSearch" type="search" placeholder="Procura em inglês ou português…" value="${esc(state.verbQuery)}" autocomplete="off"></label><select class="select-control" id="verbCategory">${categories.map(c=>`<option value="${esc(c)}" ${state.verbCategory===c?'selected':''}>${c==='all'?'Todas as categorias':esc(c)}</option>`).join('')}</select><span class="result-count">${filtered.length} verbos</span></div><div class="verb-list">${shown.map(v=>`<article class="verb-card" data-action="verb-detail" data-word="${esc(v.word)}"><div class="verb-card-head"><div><div class="verb-word">${esc(v.word)}</div><div class="pron">/${esc(v.pronunciation)}/ · ${esc(v.translation)}</div></div><span class="tag">${esc(v.category)}</span></div><div class="forms-line"><span class="form-chip">Past: ${esc(v.past)}</span><span class="form-chip">Participle: ${esc(v.participle)}</span><span class="form-chip">-ing: ${esc(v.gerund)}</span></div><div class="example-line">${esc(v.exampleEn)}<small>${esc(v.examplePt)}</small></div></article>`).join('')||`<div class="empty-state"><strong>Nenhum verbo encontrado</strong>Tenta outra palavra ou muda o filtro.</div>`}</div>${pagination(state.verbPage,total,'verb-page')}<div class="footer-note">As aproximações de pronúncia são auxiliares; confirma sons com áudio.</div></div>`;
}
function pagination(page,total,action){
  if(total<=1)return '';
  return `<div class="pagination"><button class="button button-outline button-small" data-action="${action}" data-page="${page-1}" ${page===1?'disabled':''}>← Anterior</button><span>Página ${page} de ${total}</span><button class="button button-outline button-small" data-action="${action}" data-page="${page+1}" ${page===total?'disabled':''}>Seguinte →</button></div>`;
}
function renderVocabulary(){
  const query=state.wordQuery.trim().toLowerCase();
  const positions=['all',...Array.from(new Set(DATA.vocabulary.map(v=>v.pos))).sort()];
  const known=new Set(progress.learnedWords||[]), saved=new Set(progress.savedWords||[]);
  const filtered=DATA.vocabulary.filter(w=>{
    const text=[w.word,w.translation,w.pos,w.exampleEn,w.examplePt,w.category].join(' ').toLowerCase();
    const statusMatch=state.wordFilter==='all'||(state.wordFilter==='saved'&&saved.has(w.id))||(state.wordFilter==='learned'&&known.has(w.id));
    return (!query||text.includes(query))&&(state.wordPos==='all'||w.pos===state.wordPos)&&statusMatch;
  });
  const size=30,total=Math.max(1,Math.ceil(filtered.length/size));state.wordPage=Math.min(state.wordPage,total);
  const shown=filtered.slice((state.wordPage-1)*size,state.wordPage*size);
  main.innerHTML=`<div class="page">${heading('VOCABULÁRIO ESSENCIAL','1.000 palavras e expressões','Tradução, classe, pronúncia aproximada e exemplo traduzido. Pesquisa por palavra, significado ou frase.')}<div class="toolbar"><label class="search-box"><span>⌕</span><input id="wordSearch" type="search" placeholder="Ex.: improve, trabalho, sentence…" value="${esc(state.wordQuery)}" autocomplete="off"></label><select id="wordPos" class="select-control"><option value="all">Todas as classes</option>${positions.slice(1).map(p=>`<option value="${esc(p)}" ${state.wordPos===p?'selected':''}>${esc(p)}</option>`).join('')}</select><select id="wordFilter" class="select-control"><option value="all" ${state.wordFilter==='all'?'selected':''}>Todas</option><option value="saved" ${state.wordFilter==='saved'?'selected':''}>Guardadas</option><option value="learned" ${state.wordFilter==='learned'?'selected':''}>Aprendidas</option></select><span class="result-count">${filtered.length} entradas · ${known.size} aprendidas</span></div><div class="word-list">${shown.map(w=>`<article class="word-card"><div class="word-card-head"><div><div class="verb-word">${String(w.id).padStart(4,'0')}. ${esc(w.word)}</div><div class="pron">${esc(w.pos)} · ${esc(w.pronunciation)}</div></div><div class="word-card-actions"><button class="icon-button ${saved.has(w.id)?'saved':''}" data-action="save-word" data-id="${w.id}" title="${saved.has(w.id)?'Retirar dos guardados':'Guardar palavra'}">${saved.has(w.id)?'★':'☆'}</button><button class="icon-button" data-action="speak" data-text="${esc(w.word)}" title="Ouvir">▶</button></div></div><div class="meaning">${esc(w.translation)}</div><div class="example-line">${esc(w.exampleEn)}<small>${esc(w.examplePt)}</small></div><div style="display:flex;justify-content:flex-end;margin-top:10px"><button class="text-link" data-action="word-known" data-id="${w.id}">${known.has(w.id)?'✓ Aprendida':'Marcar aprendida +'}</button></div></article>`).join('')||`<div class="empty-state"><strong>Nenhuma entrada encontrada</strong>Altera a pesquisa ou o filtro.</div>`}</div>${pagination(state.wordPage,total,'word-page')}<div class="footer-note">A lista é uma selecção pedagógica de alta utilidade, não um ranking estatístico exacto.</div></div>`;
}
function renderPractice(){
  const categories=['all',...Array.from(new Set(DATA.quizzes.map(q=>q.category))).sort()];
  const banks=DATA.quizzes.filter(b=>state.bankCategory==='all'||b.category===state.bankCategory);
  main.innerHTML=`<div class="page">${heading('PRÁTICA ACTIVA','Exercícios com feedback','Tenta responder antes de veres a solução. Cada correcção inclui a regra para aprender com o erro.')}<div class="toolbar"><select id="bankCategory" class="select-control"><option value="all">Todos os temas</option>${categories.slice(1).map(c=>`<option value="${esc(c)}" ${state.bankCategory===c?'selected':''}>${esc(c)}</option>`).join('')}</select><span class="result-count">${DATA.quizzes.reduce((n,b)=>n+b.items.length,0)} exercícios no banco</span></div><div class="grid-3">${banks.map((b,i)=>`<article class="card quiz-bank-card"><div class="bank-icon">${String(i+1).padStart(2,'0')}</div><h3>${esc(b.title)}</h3><p>${esc(b.category)} · ${b.items.length} perguntas</p><div class="bank-bottom"><span>${progress.quizStats?.[b.id]?.attempts||0} tentativas</span><span class="tag">${Math.round((progress.quizStats?.[b.id]?.best||0)*100)}% melhor</span></div><div style="display:flex;gap:7px;margin-top:12px">${button('10 questões','start-quiz',`data-id="${esc(b.id)}" data-size="10"`,'button button-primary button-small')}${button('Conjunto completo','start-quiz',`data-id="${esc(b.id)}" data-size="all"`,'button button-outline button-small')}</div></article>`).join('')}</div><div class="callout blue" style="margin-top:20px">O livro reúne 598 questões. Nesta app, os mesmos blocos estão organizados por tema; podes fazer uma sessão curta de 10 ou o conjunto completo.</div></div>`;
}
function renderQuiz(){
  if(!quizState){renderPractice();return;}
  const item=quizState.items[quizState.index];
  if(!item){renderQuizEnd();return;}
  const pct=Math.round(quizState.index/quizState.items.length*100);
  main.innerHTML=`<div class="page quiz-layout"><button class="back-link" data-action="quiz-exit">← Voltar aos exercícios</button><div class="quiz-topline"><div class="quiz-progress"><i style="width:${pct}%"></i></div><span class="quiz-count">${quizState.index+1} / ${quizState.items.length}</span></div><div class="small-label">${esc(quizState.title)}</div><section class="card quiz-card"><div class="quiz-question-label">PERGUNTA ${String(quizState.index+1).padStart(2,'0')}</div><div class="quiz-question">${esc(item.question)}</div><input id="quizAnswer" class="answer-input" placeholder="Escreve a tua resposta…" value="${esc(quizState.typed||'')}" autocomplete="off" ${quizState.answered?'disabled':''} aria-label="A tua resposta"><div id="quizFeedback"></div><div class="quiz-controls"><button class="button button-outline button-small" data-action="quiz-skip">Saltar</button>${quizState.answered?button(quizState.index+1===quizState.items.length?'Ver resultado':'Próxima pergunta →','quiz-next','','button button-primary'):button('Verificar resposta','quiz-check','','button button-primary')}</div></section><div class="footer-note">Dica: explica a regra com as tuas palavras depois de responderes.</div></div>`;
  const input=$('#quizAnswer');if(input&&!quizState.answered){input.focus();input.addEventListener('keydown',e=>{if(e.key==='Enter')checkQuiz();});}
  if(quizState.answered)showQuizFeedback();
}
function normalizeAnswer(x){return (String(x||'').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').match(/[\p{L}\p{N}]+/gu)||[]).join(' ').trim();}
function acceptableAnswers(answer){
  const source=String(answer||'').trim(), ipaSlashes=new Set(), ipaAliases=[];
  for(let i=0;i<source.length;i++){
    if(source[i]!=='/'||!source[i+1]||/\s/.test(source[i+1]))continue;
    const close=source.indexOf('/',i+1);
    if(close<0||close-i>12||/\s/.test(source.slice(i+1,close)))continue;
    const token=source.slice(i+1,close);
    if(/^[\p{L}ːˑˈˌ]+$/u.test(token)&&(/[θðɪəɑːŋʃʒʌʊæɛɜɒɔɡɹɾ]/u.test(token)||token.length<=2)){
      ipaSlashes.add(i);ipaSlashes.add(close);if(!source.slice(0,i).trim())ipaAliases.push(token);i=close;
    }
  }
  const pieces=[''];
  for(let i=0;i<source.length;i++){
    if((source[i]==='/'&&!ipaSlashes.has(i))||source[i]===';')pieces.push('');
    else pieces[pieces.length-1]+=source[i];
  }
  return Array.from(new Set([source,...pieces,...ipaAliases].map(normalizeAnswer).filter(Boolean)));
}
function checkQuiz(){
  if(!quizState||quizState.answered)return;
  const input=$('#quizAnswer');const typed=input?.value||'';if(!typed.trim()){showToast('Escreve uma resposta para continuar.');input?.focus();return;}
  const item=quizState.items[quizState.index], accepted=acceptableAnswers(item.answer), guess=normalizeAnswer(typed);
  quizState.currentCorrect=accepted.some(a=>a===guess);
  quizState.typed=typed;quizState.answered=true;
  if(quizState.currentCorrect){quizState.score++;progress.correctAnswers=(progress.correctAnswers||0)+1;}
  renderQuiz();
}
function showQuizFeedback(){
  const item=quizState.items[quizState.index], box=$('#quizFeedback');if(!box)return;
  const good=quizState.currentCorrect;
  box.innerHTML=`<div class="quiz-feedback ${good?'correct':'incorrect'}"><strong>${good?'Correcto — boa!':'Ainda não. A resposta esperada é:'}</strong>${good?'':` <b>${esc(item.answer)}</b>`}<br>${esc(item.explanation)}</div>`;
}
function nextQuizQuestion(skip=false){
  if(!quizState)return;
  if(skip&&!quizState.answered){quizState.answered=true;quizState.currentCorrect=false;quizState.typed='';renderQuiz();return;}
  if(quizState.index+1<quizState.items.length){quizState.index++;quizState.answered=false;quizState.currentCorrect=false;renderQuiz();}
  else renderQuizEnd();
}
function renderQuizEnd(){
  const q=quizState,total=q.items.length,ratio=total?q.score/total:0;
  const old=progress.quizStats?.[q.bankId]||{attempts:0,best:0};
  if(!q.saved){progress.quizStats[q.bankId]={attempts:old.attempts+1,best:Math.max(old.best,ratio),last:ratio};recordActivity(10+q.score*2);q.saved=true;}
  main.innerHTML=`<div class="page quiz-layout"><section class="card quiz-card quiz-end"><div class="eyebrow">SESSÃO CONCLUÍDA</div><div class="quiz-score">${q.score} / ${total}</div><div class="quiz-score-caption">${Math.round(ratio*100)}% de respostas certas</div><h2 class="section-heading">${ratio>=.8?'Excelente trabalho!':ratio>=.5?'Bom progresso.':'Continua a praticar — é assim que se aprende.'}</h2><p class="text-muted small">${esc(q.title)} · Ganhaste ${10+q.score*2} XP. Revê as explicações e tenta novamente daqui a alguns dias.</p><div class="lesson-footer-actions" style="justify-content:center">${button('Voltar aos exercícios','navigate','data-view="practice"','button button-primary')}${button('Repetir sessão','restart-quiz','','button button-outline')}</div></section></div>`;
}
function startQuiz(id,size='10'){
  const bank=DATA.quizzes.find(b=>b.id===id);if(!bank){showToast('Este conjunto não foi encontrado.');return;}
  const shuffled=[...bank.items].sort(()=>Math.random()-.5);
  quizState={bankId:bank.id,title:bank.title,items:size==='all'?shuffled:shuffled.slice(0,Math.min(Number(size)||10,shuffled.length)),index:0,score:0,answered:false,currentCorrect:false,saved:false};
  view='quiz';setActiveNavigation();renderQuiz();window.scrollTo({top:0,behavior:'smooth'});
}
function renderConversation(){
  main.innerHTML=`<div class="page">${heading('INGLÊS EM SITUAÇÕES REAIS','Conversação guiada','Lê, ouve, repete e representa. As pronúncias são aproximações; o botão de áudio usa a voz disponível no teu navegador.')}<div class="callout blue">Método de treino: compreende a situação → repete cada linha → faz shadowing → troca os papéis e fala sem ler.</div>${DATA.dialogues.map((d,i)=>`<section class="card dialogue-card ${state.openDialogue===i?'open':''}"><button class="dialogue-head" data-action="toggle-dialogue" data-index="${i}"><span><strong>${String(i+1).padStart(2,'0')}. ${esc(d.title)}</strong><small>${d.turns.length} falas · inglês, pronúncia e tradução</small></span><span class="tag">${state.openDialogue===i?'Fechar':'Abrir'}</span></button><div class="dialogue-body">${d.turns.map(turn=>`<div class="dialogue-turn"><div class="speaker-dot">${esc(turn.speaker.slice(0,1))}</div><div><div class="turn-en"><b>${esc(turn.speaker)}:</b> ${esc(turn.en)}</div><div class="turn-pron">${esc(turn.pronunciation)}</div><div class="turn-pt">${esc(turn.pt)}</div></div><button class="speak-button" data-action="speak" data-text="${esc(turn.en)}" title="Ouvir">▶</button></div>`).join('')}<button class="button button-outline button-small" data-action="speak" data-text="${esc(d.turns.map(t=>t.en).join(' '))}">▶ Ouvir o diálogo</button></div></section>`).join('')}<div class="footer-note">Sugestão: representa cada diálogo duas vezes, trocando os papéis.</div></div>`;
}
function renderResources(){
  const icons={home:'⌂',school:'▤',office:'▣',kitchen:'♨',hospital:'✚',travel:'↗',technology:'⌘'};
  main.innerHTML=`<div class="page">${heading('APOIO VISUAL','Cores e objectos','Cartões de referência para ampliar o vocabulário do quotidiano. Clica no áudio para ouvir a palavra.')}<section class="card ebook-banner"><div class="ebook-icon">PDF</div><div><div class="eyebrow">MATERIAL DE ESTUDO</div><h2>O e-book completo do curso</h2><p>Learning English — Do Básico ao Inglês Profissional · 177 páginas para leitura e estudo offline.</p><a class="button button-primary" href="./downloads/Learning_English_Edmilson_Arlindo.pdf" download>Baixar o e-book →</a></div></section><h2 class="section-heading">Cores</h2><div class="color-grid">${DATA.colors.map(c=>`<article class="color-card"><div class="color-swatch" style="background:#${esc(c.hex)}"></div><div><strong>${esc(c.name)} — ${esc(c.translation)}</strong><small>${esc(c.pronunciation)}</small><div class="example-line">${esc(c.exampleEn)}<small>${esc(c.examplePt)}</small></div><button class="text-link" data-action="speak" data-text="${esc(c.name.split(' /')[0])}">▶ Ouvir</button></div></article>`).join('')}</div><h2 class="section-heading">Objectos do dia-a-dia</h2>${DATA.objects.map(group=>`<section class="object-section"><div class="object-heading"><div class="object-icon">${icons[group.icon]||'◈'}</div><div><h3>${esc(group.category)}</h3><small>${group.items.length} palavras com pronúncia aproximada</small></div></div><div class="object-grid">${group.items.map(item=>`<article class="object-item"><strong>${esc(item.word)}</strong><small>${esc(item.translation)}</small><em>${esc(item.pronunciation)}</em><button class="text-link" data-action="speak" data-text="${esc(item.word)}">▶ ouvir</button></article>`).join('')}</div></section>`).join('')}</div>`;
}
function renderProfile(){
  const lessons=DATA.tenses.map((t,i)=>{const done=(progress.completedLessons||[]).includes(t.key);return `<div class="progress-row"><span>${String(i+1).padStart(2,'0')} · ${esc(t.name.split(' —')[0])}</span><div class="mini-progress"><i style="width:${done?100:0}%"></i></div><span>${done?'100%':'—'}</span></div>`;}).join('');
  const learned=(progress.learnedWords||[]).length,saved=(progress.savedWords||[]).length,quizzes=Object.values(progress.quizStats||{}),attempts=quizzes.reduce((n,q)=>n+q.attempts,0),best=quizzes.length?Math.round(Math.max(...quizzes.map(q=>q.best))*100):0;
  main.innerHTML=`<div class="page">${heading('O MEU ESPAÇO','Progresso de aprendizagem','Os teus dados ficam guardados neste dispositivo.')}<div class="profile-hero"><div class="profile-monogram">EA</div><div><h2>Edmilson Arlindo</h2><p>${esc(DATA.school)} · ${esc(formatLevel())}</p></div></div><section class="stats-grid" style="margin-top:16px"><div class="stat-card"><div class="stat-icon gold">✦</div><div><strong>${progress.xp||0}</strong><small>XP acumulados</small></div></div><div class="stat-card"><div class="stat-icon">🔥</div><div><strong>${progress.streak||0}</strong><small>Dias seguidos</small></div></div><div class="stat-card"><div class="stat-icon">✓</div><div><strong>${attempts}</strong><small>Práticas concluídas</small></div></div><div class="stat-card"><div class="stat-icon">★</div><div><strong>${best}%</strong><small>Melhor resultado</small></div></div></section><section class="card card-pad"><div class="card-title-row"><div><h2 class="card-title">Progresso nas lições</h2><p class="card-subtitle">Marca as unidades quando terminares o estudo e a revisão.</p></div><span class="tag gold">${(progress.completedLessons||[]).length} / 12</span></div><div class="progress-list" style="margin-top:18px">${lessons}</div></section><div class="grid-2" style="margin-top:15px"><section class="card card-pad">${panelTitle('Vocabulário pessoal','As palavras que estás a guardar.') }<p class="section-heading">${learned} aprendidas · ${saved} guardadas</p><button class="button button-outline button-small" data-action="navigate" data-view="vocabulary">Abrir vocabulário</button></section><section class="card card-pad">${panelTitle('Dados locais','O progresso fica neste navegador.') }<p class="small text-muted">Se limpares os dados do navegador ou mudares de dispositivo, o progresso poderá ser perdido.</p><button class="button button-outline button-small" data-action="reset-progress">Repor progresso</button></section><section class="card card-pad">${panelTitle('Instalar no dispositivo','A app também pode ficar no ecrã inicial.') }<p class="small text-muted">Android/Chrome: menu ⋮ → “Instalar app” ou “Adicionar ao ecrã inicial”. iPhone/iPad: abre no Safari, toca em Partilhar e escolhe “Adicionar ao ecrã principal”. No computador, usa o ícone de instalação do navegador quando aparecer.</p></section><section class="card card-pad">${panelTitle('Contacto do curso','Escola do Conhecimento · Edmilson Arlindo') }<p class="small text-muted">Telefone: <a href="tel:866309994">866309994</a> · <a href="tel:843933721">843933721</a><br>E-mail: <a href="mailto:edmilsonarlindo9090@gmail.com">edmilsonarlindo9090@gmail.com</a></p></section></div></div>`;
}
function render(){
  if(!DATA)return;
  updateChrome();setActiveNavigation();
  if(view==='home')renderHome();
  else if(view==='lessons')renderLessons();
  else if(view==='lesson')renderLesson(state.currentLesson);
  else if(view==='verbs')renderVerbs();
  else if(view==='vocabulary')renderVocabulary();
  else if(view==='practice')renderPractice();
  else if(view==='quiz')renderQuiz();
  else if(view==='conversation')renderConversation();
  else if(view==='resources')renderResources();
  else if(view==='profile')renderProfile();
  else renderHome();
}
function openVerb(word){
  const v=DATA.verbs.find(x=>x.word===word);if(!v)return;
  modalLayer.innerHTML=`<div class="modal" role="dialog" aria-modal="true"><div class="modal-header"><div><div class="eyebrow">DICIONÁRIO DE VERBOS · ${esc(v.category)}</div><h2>${esc(v.word.toUpperCase())}</h2><div class="pron">/${esc(v.pronunciation)}/</div></div><button class="modal-close" data-action="close-modal" aria-label="Fechar">×</button></div><p><strong>Significado:</strong> ${esc(v.translation)}</p><div class="table-wrap"><table class="data-table"><tbody><tr><th>Base</th><td>${esc(v.base)}</td></tr><tr><th>Past Simple</th><td>${esc(v.past)}</td></tr><tr><th>Past Participle</th><td>${esc(v.participle)}</td></tr><tr><th>Gerund</th><td>${esc(v.gerund)}</td></tr></tbody></table></div><div class="example-line" style="margin-top:15px">${esc(v.exampleEn)}<small>${esc(v.examplePt)}</small></div>${v.note?`<div class="callout blue">${esc(v.note)}</div>`:''}<div class="lesson-footer-actions"><button class="button button-primary" data-action="speak" data-text="${esc(v.exampleEn)}">▶ Ouvir exemplo</button><button class="button button-outline" data-action="close-modal">Fechar</button></div></div>`;
  modalLayer.classList.add('open');modalLayer.setAttribute('aria-hidden','false');
}
function closeModal(){modalLayer.classList.remove('open');modalLayer.setAttribute('aria-hidden','true');modalLayer.innerHTML='';}
function handleInput(e){
  const el=e.target;
  if(el.id==='verbSearch'){state.verbQuery=el.value;state.verbPage=1;renderVerbs();focusAt('#verbSearch',el.value.length);}
  if(el.id==='wordSearch'){state.wordQuery=el.value;state.wordPage=1;renderVocabulary();focusAt('#wordSearch',el.value.length);}
}
function focusAt(selector,pos){const el=$(selector);if(el){el.focus();try{el.setSelectionRange(pos,pos);}catch(e){}}}
function handleClick(e){
  const btn=e.target.closest('[data-action]');if(!btn)return;
  const action=btn.dataset.action;
  if(action==='navigate'){go(btn.dataset.view);return;}
  if(action==='open-next'){go('lesson',nextLesson().key);return;}
  if(action==='open-lesson'){go('lesson',btn.dataset.id);return;}
  if(action==='complete-lesson'){
    const id=btn.dataset.id;
    if(!(progress.completedLessons||[]).includes(id)){progress.completedLessons.push(id);recordActivity(20);showToast('Lição concluída · +20 XP');}
    else showToast('Esta lição já está marcada como concluída.');
    view='lesson';state.currentLesson=id;render();return;
  }
  if(action==='open-quiz'){startQuiz(btn.dataset.id,'10');return;}
  if(action==='start-quiz'){startQuiz(btn.dataset.id,btn.dataset.size);return;}
  if(action==='start-random'){
    const bank=DATA.quizzes[Math.floor(Math.random()*DATA.quizzes.length)];startQuiz(bank.id,'10');return;
  }
  if(action==='quiz-check'){checkQuiz();return;}
  if(action==='quiz-next'){nextQuizQuestion();return;}
  if(action==='quiz-skip'){nextQuizQuestion(true);return;}
  if(action==='quiz-exit'){quizState=null;go('practice');return;}
  if(action==='restart-quiz'){const id=quizState?.bankId;startQuiz(id,'10');return;}
  if(action==='verb-detail'){openVerb(btn.dataset.word);return;}
  if(action==='close-modal'){closeModal();return;}
  if(action==='speak'){speak(btn.dataset.text||'');return;}
  if(action==='save-word'){
    const id=Number(btn.dataset.id),list=new Set(progress.savedWords||[]);
    if(list.has(id)){list.delete(id);showToast('Removida dos guardados.');}else{list.add(id);showToast('Palavra guardada.');}
    progress.savedWords=Array.from(list);saveProgress();if(view==='vocabulary')renderVocabulary();else if(modalLayer.classList.contains('open')){}return;
  }
  if(action==='word-known'){
    const id=Number(btn.dataset.id),list=new Set(progress.learnedWords||[]);
    if(!list.has(id)){list.add(id);progress.learnedWords=Array.from(list);recordActivity(2);showToast('Marcada como aprendida · +2 XP');}
    else{list.delete(id);progress.learnedWords=Array.from(list);saveProgress();showToast('Retirada da lista aprendida.');}
    renderVocabulary();return;
  }
  if(action==='verb-page'){state.verbPage=Number(btn.dataset.page);renderVerbs();return;}
  if(action==='word-page'){state.wordPage=Number(btn.dataset.page);renderVocabulary();return;}
  if(action==='toggle-dialogue'){state.openDialogue=state.openDialogue===Number(btn.dataset.index)?-1:Number(btn.dataset.index);renderConversation();return;}
  if(action==='reset-progress'){
    if(confirm('Queres mesmo repor todo o progresso guardado neste dispositivo?')){localStorage.removeItem(STORAGE_KEY);progress=loadProgress();showToast('Progresso reposto.');renderProfile();}return;
  }
}
function handleChange(e){
  if(e.target.id==='verbCategory'){state.verbCategory=e.target.value;state.verbPage=1;renderVerbs();}
  if(e.target.id==='wordPos'){state.wordPos=e.target.value;state.wordPage=1;renderVocabulary();}
  if(e.target.id==='wordFilter'){state.wordFilter=e.target.value;state.wordPage=1;renderVocabulary();}
  if(e.target.id==='bankCategory'){state.bankCategory=e.target.value;renderPractice();}
}
main.addEventListener('input',handleInput);
main.addEventListener('change',handleChange);
document.addEventListener('click',handleClick);
$('#mobileMenu').addEventListener('click',()=>$('#sidebar').classList.toggle('open'));
modalLayer.addEventListener('click',e=>{if(e.target===modalLayer)closeModal();});
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeModal();});

window.addEventListener('beforeinstallprompt',e=>{e.preventDefault();deferredInstall=e;$('#installButton').hidden=false;});
$('#installButton').addEventListener('click',async()=>{if(!deferredInstall){showToast('Vê “O meu progresso” para instruções de instalação no teu dispositivo.');return;}deferredInstall.prompt();await deferredInstall.userChoice;deferredInstall=null;$('#installButton').hidden=true;});
window.addEventListener('appinstalled',()=>showToast('App instalado com sucesso.'));

async function init(){
  try{
    const res=await fetch('./data.json');if(!res.ok)throw new Error('Não foi possível carregar os dados.');
    DATA=await res.json();
    if('serviceWorker' in navigator){navigator.serviceWorker.register('./sw.js').catch(()=>{});}
    render();
  }catch(err){main.innerHTML=`<div class="empty-state"><strong>Não foi possível abrir o curso.</strong>Actualiza a página ou verifica se todos os ficheiros do app estão na mesma pasta.<br><small>${esc(err.message)}</small></div>`;}
}
init();
