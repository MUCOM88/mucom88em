******************************************************************************
MUCOM88 Extended Memory Edition document

OpenMucom88 Ver.1.7 Copyright 1987-2019(C) Yuzo Koshiro
PC-8801 Extended Memory Edition by MUCOM™ 2019(C)
******************************************************************************


■はじめに

MUCOM88 Extended Memory Edition(以下、MUCOM88em)は、古代祐三氏による
PC-8801シリーズ用のFM音源ツール/ドライバ「MUCOM88」を拡張メモリに対応させた
システムです。

従来、コンパイル後のデータサイズにして最大で約8.5KBが製作できる楽曲の限界
でしたが、MUCOM88emは最大32KBまでの大きなサイズの楽曲を扱う事が可能です。


■動作環境

・NEC PC-8801mkⅡSR以降(サウンドボードⅡ対応)
  【要・32KB以上の拡張メモリ】(MR/MH/MA/MA2/MC/VA/VA2/VA3/Do/Do+は標準装備)
  (PC-8801MC/FE2の8MHzHモードでは、YM2608のリズム音源が正常に演奏されない場合
がありますので、8MHzSモードでご使用ください。)
・PC-8801mkⅡSR以降対応の各種エミュレータ


■使用方法

使用方法はオリジナルのMUCOM88 Ver.1.7に準じます。
(ただし一部の機能は操作が異なる場合があります。)

(参考)
OPEN MUCOM PROJECT (株式会社エインシャント様)
https://www.ancient.co.jp/~mucom88/
Open MUCOM88 Wiki (onionsoftware/おにたま様)
https://github.com/onitama/mucom88/wiki

動作イメージファイル(D88)の作成方法は同梱のドキュメント「making.txt」をご参照
下さい。


■ライセンスについて

オリジナルのMUCOM88SDKのライセンスに準じます。

Name        : MUCOM88 Extended Memory Edition
Platform    : The Nippon Electric Company (NEC) PC-8801 Series. v1/v2 mode,
Repository/Download site : https://github.com/MUCOM88/mucom88/
License     : CC BY-NC-SA 4.0
Copyright   : Yuzo Koshiro 2018
MUcOM88 Extended Memory Edition by MUCOM™ 2019(C)

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from 
the use of this software.

Attribution-NonCommercial-NoDerivatives 4.0 International.
https://creativecommons.org/licenses/by-nc-sa/4.0/deed.ja

1. Attribution:
   You must give appropriate credit, provide a link to the license, and indicate
   if changes were made. You may do so in any reasonable manner, but not in any
   way that suggests the licensor endorses you or your use.

2. NonCommercial:
   You may not use the material for commercial purposes.

3. ShareAlike:
   If you remix, transform, or build upon the material, you must distribute
   your contributions under the same license as the original.


■更新履歴

2019/10/22 v0.10(MUCOM88em 20191022) 公開日
           ・曲バイナリデータ領域をメインRAMから拡張RAMに移動させ、
             曲バイナリデータ領域のサイズを約8.5KBから32KBに拡大、及び
             曲バイナリデータ領域と演奏モニタ及びPCMデータアドレス情報の領域競合を改善。
           ・MMLソース領域とFM音色エディタ及びSSGプリセット音色データの領域競合を改善。
2019/10/25 v0.20(MUCOM88em 20191025) 改修
           ・FMプリセット音色データをメインRAMから拡張RAMに移動させ、
           ・曲バイナリデータ領域とFMプリセット音色データの領域競合を改善。
           ・起動時の拡張メモリ搭載チェック機構を追加。
           ・FMプリセット音色(@0、@1)が壊れる仕様バグの修正。
2019/11/17 v0.30(MUCOM88em 20191117) 改修
           ・Jコマンドが正常に動作しないバグの修正。
           ・FM音色エディタをメインRAMから拡張RAMに移動させ、
             メインメモリのフリーエリアを拡大。
           ・起動時の拡張メモリ搭載チェック機構を改良。
