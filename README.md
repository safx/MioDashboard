MioDashboard
============

IIJmioの[クーポンスイッチAPI](https://www.iijmio.jp/guide/outline/hdd/mioponapi.jsp)を利用したiOSサンプルアプリケーションです。

Screenshots
===========

![](images/dashboard1.jpg)
![](images/dashboard2.jpg)
![](images/dashboard3.jpg)

How to Use
==========

あらかじめ、[IIJmioクーポンスイッチAPI](https://api.iijmio.jp/mobile/d/)のディベロッパIDを取得する必要があります。

ディベロッパIDを取得後に、MioRestHelper.mにデベロッパIDとリダイレクトURIを設定の上、コンパイルしてください。

            instance.clientID = @"取得したデベロッパID";
            instance.redirectURI = @"リダイレクトURI";

License
=======

MIT
