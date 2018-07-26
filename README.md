# MastodonUpdateScript
## 概要
Mastodonのインストール＆アップデートをよしなにしてくれるもの

基本的に、[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)通りにインスタンスを設置します。

独自実装などをしているなどの場合は適宜書き換えてご使用ください。

## Mastodonのインストール

まず、`git clone` し、作成した `script` ディレクトリに移動します。

```
git clone https://github.com/S-H-GAMELINKS/MastodonScript.git script　&& cd script
```

次に、`env_setting.sh` を実行し、`mastodon`アカウントを作成

```
sh env_setting.sh
```

作成した`mastodon`アカウントに切り替え、`git clone`を実行。
同様に、`script`ディレクトリに移動します。

```
su - mastodon
git clone https://github.com/S-H-GAMELINKS/MastodonScript.git script　&& cd script
```

rbenvをインストールする`shell`を実行。

```
sh rbenv_install.sh
```

その後、一旦`bash`を再起動。

```
exec bash
```

そして、Rubyをインストールする。

```
sh ruby_install.sh
```

Mastodonのリポジトリを`clone`し、`bundle install`とかをしてくれる`mastodon_install.sh`を実行。

```
sh mastodon_install.sh
```



## 参考

[ゼロからはじめるMastodon インスタンス運用編](https://knowledge.sakura.ad.jp/8683/)

[Mastodon Production Guide](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)
