-- カスタムスタイルテーブルの作成
CREATE TABLE custom_styles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  prompt TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成（検索高速化）
CREATE INDEX idx_custom_styles_user_id ON custom_styles(user_id);
CREATE INDEX idx_custom_styles_created_at ON custom_styles(created_at DESC);

-- Row Level Security (RLS) を有効化
ALTER TABLE custom_styles ENABLE ROW LEVEL SECURITY;

-- ポリシー: ユーザーは自分のカスタムスタイルのみ読み取り可能
CREATE POLICY "Users can read own custom styles"
  ON custom_styles FOR SELECT
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のカスタムスタイルのみ挿入可能
CREATE POLICY "Users can insert own custom styles"
  ON custom_styles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のカスタムスタイルのみ更新可能
CREATE POLICY "Users can update own custom styles"
  ON custom_styles FOR UPDATE
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のカスタムスタイルのみ削除可能
CREATE POLICY "Users can delete own custom styles"
  ON custom_styles FOR DELETE
  USING (auth.uid() = user_id);
