contra-nes-translation
----------------------

魂斗罗 1 - FC 汉化代码

License: BSD 3-Clause License; p65: See `LICENSE.txt` inside corresponding directory.

---

翻译项目是在 2016 年做的，很多资料已经不见了… 只在硬盘里找到这些文件。

于是将这些文件放出来；如果有人能从这里发现或学习到什么也算好了。

印象中是手动编译一部分然后手动填充进 ROM 内，后来应该是直接编译出一个 `*.bin` 文件放到固定的位置，然后
根据 `04,AB70-GenericDisplayCharacter.s` 文件头部的函数表手动修改对应的位置跳转过来。

字模辅助工具在 [JixunMoe/ContraFontTool][ContraFontTool]，印象中也是手动粘贴位图然后粘贴 HEX 代码到对应的位置…

当初记录的汉化过程可以参考我以前博客：
https://blog.jixun.moe/fc-contra-chinese-translation-diary-1

---

发布：

* [我的博客](https://jixun.moe/post/fc-contra-1)
* [RHDN (romhacking.net)](https://www.romhacking.net/translations/2685/)
* [博客 (旧)](https://blog.jixun.moe/fc-contra-chinese)
* 以及一些其他地方…

---

关于 repo 里的 `p65`：

应该是 2016 年在[P65](https://hkn.eecs.berkeley.edu/~mcmartin/P65/)
（[存档](https://web.archive.org/web/20160629233630/https://hkn.eecs.berkeley.edu/~mcmartin/P65/)）
下载的，本地留了一份。

`p65-py3` 是我试着对源码进行了简单的修改来让它支持在 Python 3 下编译 `src` 目录下的代码，正确性未测试。

[ContraFontTool]: https://github.com/JixunMoe/ContraFontTool
