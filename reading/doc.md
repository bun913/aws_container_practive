# AWS コンテナ設計・構築本格入門

[この書籍](https://www.amazon.co.jp/dp/B09DKZC1ZH/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1)を手を動かしながら学習

## Chapter1

コンテナ技術の解説

コンテナの利点

- 依存関係をコンテナ中に閉じ込めることができる
  - こっちのサブアプリでは Python 環境
  - あっちでは TypeScript
  - こっちでは Python version 違い
- 再起動性・構築性が高い
  - イメージがあれば何度でも同じ環境を作成できるし壊して良い
- サーバー仮想化と比べて軽い

この辺りがあげられている

## Chapter2

AWS が提供しているコントロールプレーン

ここでいうコントロールプレーンはこんてなを管理する機能のこと

コンテナを動かす実行環境のことではない

### ECS

SLA で月間稼働率が 99.99%であることが保証

- タスク
  - コンテナが動作するコンポーネントをタスクと呼んでいる
- タスク定義
  - JSON で記述。
  - デプロイするコンテナイメージ・IAM ロール・CloudWatchLogs の出力などを定義
- サービス
  - 指定した数だけタスクを維持するスケジューラー
- クラスター
  - サービスとタスクを実行する論理グループ

## データプレーン

EC2 と Fargate がある

Fargate はコンテナ向けサーバレスコンピューティングエンジン

メリット

- ホスト管理が不要
  - アプリケーションのことだけに集中できる

デメリット

- 価格が高い
  - 以前よりかなり安くなっている
  - でも EC2 よりも高い
- OS に介入できない
- CPU・メモリの制限やコンテナ画起動するまでの時間が少し遅い

なお SSH 接続による調査がしにくいという問題があったが、
[ECS Exec](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/ecs-exec.html)というサービスができている

## Chapter3

### 運用設計

- どのようにシステムの状態を把握するか
- どのように不具合の修正を容易にするか
- どのようにデプロイのリスクを軽減するか

### ロギング設計

- CloudWatchLogs
  - これが標準的
  - 大量にログが出力されるケースでは不向き(自分も痛い目見たことある)
- Firelens
  - fluentd や fluentbit が利用できる
  - AWS も fluentbit を推奨している
  - fluentbid の場合 AWS が公式に提供しているコンテナイメージを使える
  - faragate のタスク定義の中にアプリケーションコンテナと fluentbid コンテナを同梱させる

Firelens を利用することで　 S3 だけでなく CloudWatchLogs に転送することもできる。
ログドライバーとして FireLens を指定する(CloudWatchDriver だとコストが高くなる)

### メトリクス設計

基本的な CloudWatch メトリクス

- CPU 使用率
- メモリ使用率

この辺りはデフォで利用できる。

ただあくまでサービス単位であってタスクごとの情報は表示できない。

`Container Insights` で他の情報も表示できる。

### トレース設計

Fluentbid と同じく、サービスに`X-Ray`コンテナをタスクとして同梱させることで、システム全体の可視化もできる。

### CI・CD 設計

Code シリーズを利用する。開発・ステージング・本番と３つの環境を用意することを想定。

- CodeCommit
  - 各環境で１つのリポジトリを利用する
  - 環境ごとにブランチを分けて管理する
- CodeBuild
  - 環境ごとに分離して配置する
  - 各環境で違うことをしようとするのに、共有すると複雑さが増す
  - 素直に分離して配置した方が良い
- CodeDeploy
  - 環境ごとに分離して配置する

ステージングと本番のイメージを同じにするように、ステージングで作成したイメージを本番で利用する。

CI/CD をするには、アプリケーション開発が本格化する前に！

### 踏み台ホスト管理

- 従来のようにパブリックサブネットに EC2 を配置する必要はない
- EC2 を利用しちゃうとせっかくコンテナ化したのに、そこで OS の管理などが必要になる
- プライベートサブネットに SSM マネージャーをインストールしたコンテナイメージを ECS で用意
- そこを経由して各サービスに SessionManager 経由でコマンドを打ち込めば良い

### セキュリティ管理

イメージの脆弱性に対する対策

- ECR による脆弱性スキャン
  - Trivy を利用
  - CodeBuild のワークフローファイルなどに記述することで簡単にスキャンできる
- イメージ自体への対応
  - Dockle を利用
  - 例えば root 権限でコンテナを起動しているなどの、セキュリティをチェック
  - Docker のベストプラクティスに則った状態かなどをチェック

他にも書き切れないが参考になることが山ほど

### パフォーマンス設計

- Fargate 上で稼働する ECS タスクには ENI が提供されて、自動でプライベート IP アドレスが付与されている
- あまりに大量に稼働させる場合、その分 IP アドレスの枯渇に気を使う必要がある

スケールアウト戦略

- ステップスケーリングポリシー
  - CPU 使用率などを目処にスケールアウト・スケールインの利用を決めておく
  - ステップを複数段階定義しておくことで段階的にスケールアウトが可能
- ターゲット追跡スケーリングポリシー
  - 指定したメトリクスのターゲット値を維持するようにスケールアウトやスケールインがされる
  - 管理が楽
  - メトリクスがターゲット値を超えている場合にもにスケールアウトする挙動
  - スケールインは緩やかに実行される

設定項目が少なく運用も楽なターゲット追跡スケーリングポリシーが楽そう

### コスト最適化設計

見落としがちなのが通信コスト

Fargate では基本的にイメージをキャッシュしない

つまりスケールアウトするたびに ECR からイメージを取得している

そのため ECR へのイメージが小さいほど通信コストも削減できる