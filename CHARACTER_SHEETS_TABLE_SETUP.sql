-- キャラクターシートテーブルの作成
CREATE TABLE character_sheets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  style_id INTEGER,
  style_name TEXT,
  sheet_image_url TEXT NOT NULL,
  base_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成（検索高速化）
CREATE INDEX idx_character_sheets_user_id ON character_sheets(user_id);
CREATE INDEX idx_character_sheets_created_at ON character_sheets(created_at DESC);

-- Row Level Security (RLS) を有効化
ALTER TABLE character_sheets ENABLE ROW LEVEL SECURITY;

-- ポリシー: ユーザーは自分のキャラクターシートのみ読み取り可能
CREATE POLICY "Users can read own character sheets"
  ON character_sheets FOR SELECT
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のキャラクターシートのみ挿入可能
CREATE POLICY "Users can insert own character sheets"
  ON character_sheets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のキャラクターシートのみ更新可能
CREATE POLICY "Users can update own character sheets"
  ON character_sheets FOR UPDATE
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のキャラクターシートのみ削除可能
CREATE POLICY "Users can delete own character sheets"
  ON character_sheets FOR DELETE
  USING (auth.uid() = user_id);
