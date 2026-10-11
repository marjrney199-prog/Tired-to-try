-- Esquema SQLite local (Android/iOS). Todas as consultas da aplicação usam
-- argumentos posicionais; não concatene valores do utilizador no SQL.
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  recovery_hash TEXT NOT NULL,
  recovery_salt TEXT NOT NULL,
  created_at TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE progress (
  user_id TEXT NOT NULL,
  language TEXT NOT NULL,
  level TEXT NOT NULL,
  xp INTEGER NOT NULL DEFAULT 0,
  lessons_completed INTEGER NOT NULL DEFAULT 0,
  streak INTEGER NOT NULL DEFAULT 0,
  last_active TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (user_id, language, level)
);

CREATE TABLE completions (
  user_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  language TEXT NOT NULL,
  level TEXT NOT NULL,
  score INTEGER NOT NULL,
  completed_at TEXT NOT NULL,
  PRIMARY KEY (user_id, lesson_id)
);

CREATE TABLE history (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  source_language TEXT NOT NULL,
  target_language TEXT NOT NULL,
  input_text TEXT NOT NULL,
  output_text TEXT NOT NULL,
  created_at TEXT NOT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE word_favorites (
  user_id TEXT NOT NULL,
  language TEXT NOT NULL,
  word TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (user_id, language, word)
);

CREATE TABLE certificates (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  language TEXT NOT NULL,
  level TEXT NOT NULL,
  score INTEGER NOT NULL,
  issued_at TEXT NOT NULL
);

CREATE UNIQUE INDEX idx_users_email_unique ON users(email) WHERE email <> '';
CREATE INDEX idx_history_user_created ON history(user_id, created_at DESC);
CREATE INDEX idx_completions_user_level ON completions(user_id, language, level);
