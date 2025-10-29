# src/invidious/github_storage.cr

require "json"
require "file_utils"
require "process"

# Invidious::Database の機能を代替するクラス
class Invidious::GitHubStorage
  # シングルトンパターン（インスタンスは一つだけ）を実装
  @@instance : GitHubStorage? = nil

  # Git操作に必要な設定をここで定義（環境変数などから取得）
  GITHUB_REPO_PATH = "." # クローンしたリポジトリのルート
  
  # GitHubのPersonal Access Token (PAT) は環境変数から取得
  GITHUB_DATA_TOKEN = ENV["GITHUB_DATA_TOKEN"]?

  def initialize
    # データを保存するディレクトリがなければ作成
    FileUtils.mkdir_p("data/user")
    puts "GitHubStorage: Data directory initialized."
  end

  # シングルトンインスタンスを取得するためのメソッド
  def self.instance
    @@instance ||= self.new
  end

  # --- Git/GitHub 同期ロジック ---

  # ローカルの変更をGitHubにプッシュする
  def sync_to_github(file_paths : Array(String))
    # 認証情報（PAT）がない場合は、同期せず警告を出して終了
    unless GITHUB_DATA_TOKEN
      puts "GitHubStorage: ⚠️ GITHUB_DATA_TOKEN not set. Skipping Git sync."
      return
    end

    # 変更をステージング (git add)
    file_paths.each do |path|
      Process.run("git add #{path}", chdir: GITHUB_REPO_PATH)
    end

    # コミット
    commit_message = "Automated data sync for #{Time.now.to_s}"
    commit_result = Process.run(%Q(git commit -m "#{commit_message}"), chdir: GITHUB_REPO_PATH, output: STDOUT, error: STDERR)
    
    # コミットに成功した場合のみプッシュ
    if commit_result.exit_code == 0
      # 認証情報を使ったリモートURLの設定 (実際の環境に合わせて調整が必要)
      # 例: git remote set-url origin https://<PAT>@github.com/user/repo.git
      # ここではシンプルに、リモートが正しく設定されている前提でプッシュ
      push_result = Process.run("git push origin main", chdir: GITHUB_REPO_PATH, output: STDOUT, error: STDERR)
      
      if push_result.exit_code == 0
        puts "GitHubStorage: ✅ Data successfully pushed to GitHub."
      else
        puts "GitHubStorage: ❌ Git push failed. Error: #{push_result.error}"
      end
    elsif commit_result.error.includes?("nothing to commit")
      puts "GitHubStorage: Nothing to commit."
    else
      puts "GitHubStorage: ❌ Git commit failed. Error: #{commit_result.error}"
    end
  end

  # --- ユーザーデータ操作の代替スタブ（これから実装）---
  
  # ユーザーの購読リストをファイルからロード
  def load_subscriptions(user_id)
    # TODO: user_id に基づいたファイル名を作成し、JSONを読み込む
    [] of String # 仮の空リストを返す
  end

  # ユーザーの購読リストをファイルに保存し、GitHubに同期
  def save_subscriptions(user_id, subscriptions)
    file_path = "data/user/#{user_id}_subs.json"
    File.write(file_path, subscriptions.to_json) # CrystalのオブジェクトをJSONに変換して保存
    
    # Git同期を呼び出す
    sync_to_github([file_path])
  end
  
  # ... 他のデータ操作メソッド (ユーザー設定、セッションなど) もここに追加
end

# Invidious モジュールにエイリアスを設定
module Invidious
  # DB接続の代わりに、GitHubStorageのインスタンスを定数として定義
  # どこからでも Invidious::STORAGE でアクセスできるようにする
  STORAGE = GitHubStorage.instance
end
