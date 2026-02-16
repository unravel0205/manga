-- 漫画履歴テーブルの作成
CREATE TABLE mangas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  story TEXT,
  style_id INTEGER,
  style_name TEXT,
  settings JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成（検索高速化）
CREATE INDEX idx_mangas_user_id ON mangas(user_id);
CREATE INDEX idx_mangas_created_at ON mangas(created_at DESC);

-- Row Level Security (RLS) を有効化
ALTER TABLE mangas ENABLE ROW LEVEL SECURITY;

-- ポリシー: ユーザーは自分の漫画のみ読み取り可能
CREATE POLICY "Users can read own mangas"
  ON mangas FOR SELECT
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分の漫画のみ挿入可能
CREATE POLICY "Users can insert own mangas"
  ON mangas FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ポリシー: ユーザーは自分の漫画のみ削除可能
CREATE POLICY "Users can delete own mangas"
  ON mangas FOR DELETE
  USING (auth.uid() = user_id);
