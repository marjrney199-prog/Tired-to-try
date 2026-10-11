# Learning English — Escola do Conhecimento

PWA instalável e responsiva para acompanhar o curso de inglês de Edmilson Arlindo. Não requer servidor de aplicação, conta ou dependências externas.

## Conteúdo incluído

- 12 lições de tempos verbais, com explicação, fórmula, usos, regras, exemplos, pronúncia aproximada, erros comuns e contraste.
- Dicionário interactivo com 236 verbos e formas base, passado, particípio e gerúndio.
- Pesquisa em 1.000 palavras/expressões, com tradução, classe gramatical, pronúncia aproximada e exemplo bilingue.
- 23 conjuntos de exercícios, com 598 perguntas, correcção e explicação.
- 10 diálogos com tradução, pronúncia e leitura áudio do navegador.
- Cores, objectos, acompanhamento do progresso e pontos de estudo.
- E-book PDF de 177 páginas para baixar dentro da app.
- Progresso, palavras guardadas e lições concluídas guardados localmente no navegador.

## Executar localmente

Não abras `index.html` directamente como `file://`, porque o navegador pode bloquear a leitura de `data.json`. Na pasta do projecto, inicia um servidor estático:

```bash
python3 -m http.server 8000
```

Depois abre `http://localhost:8000`. Para instalar num dispositivo através de uma rede ou alojamento público, publica a pasta inteira num domínio com HTTPS. O service worker e a instalação PWA precisam de HTTPS (excepto em `localhost`).

## Instalar

- **Android / Chrome:** abre o menu do navegador e escolhe “Instalar app” ou “Adicionar ao ecrã inicial”.
- **iPhone / iPad:** abre a página no Safari → Partilhar → “Adicionar ao ecrã principal”.
- **Computador:** usa o ícone de instalação ou a opção equivalente do Chrome/Edge.

Abre a app uma primeira vez com ligação à internet para guardar os ficheiros para uso offline. O e-book também fica incluído no cache offline após a instalação.

## Ficheiros principais

- `index.html`, `styles.css`, `app.js` — interface e lógica.
- `data.json` — conteúdo pedagógico exportado do e-book.
- `manifest.webmanifest`, `sw.js` — configuração PWA e cache offline.
- `assets/` — logótipo e ícones da app.
- `downloads/Learning_English_Edmilson_Arlindo.pdf` — e-book incluído.

## Notas

- O progresso é guardado apenas no navegador/dispositivo actual; não existe sincronização em nuvem.
- A leitura áudio usa as vozes inglesas disponíveis no sistema operativo/navegador. A qualidade e o sotaque variam por dispositivo.
- As transcrições de pronúncia simplificadas são auxiliares didácticos, não substituem o IPA nem a prática com áudio.

**Escola do Conhecimento · Edmilson Arlindo**  
866309994 · 843933721  
[edmilsonarlindo9090@gmail.com](mailto:edmilsonarlindo9090@gmail.com)

> O relógio tem preço, mas só o tempo tem valor.
