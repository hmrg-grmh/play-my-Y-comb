`<!-- 递归与奇迹 -->`  
`<# 头图来自萌娘百科，地址： https://zh.moegirl.org.cn/File:Bg_chara_201912.png #>`  

# 前言


> ***我把一些令人兴奋的事情称呼为奇迹🙃🙃🙃🙃🐊***  
> 


目前有三部分：

- 第一部分 - `从递归到尾递归`：整理了一些 *非尾递归转写为尾递归的案例* 。起初只是因为非尾递归作者看着觉得费劲。***🦑而且不妨想想看，如果一般递归都能改成尾递归，性能优化不就有指望了嘛！当然事实上不是啥递归都能这么搞。***
- 第二部分 - `天才与爆栈！❄`：发现了一个可以用来轻松制造栈溢出（或类似）现象的方案，这个思路就是递归减实现模算数，顺便这部分还玩了梗。哦对了， *有各个语言应用这个方案的示例* 。***🦑其实这个部分只是我自己兴奋而已，或者说，为更大的兴奋而做的铺垫……？（所以什么是更大的兴奋呢？🙃）***
- 第三部分 - `无穷无尽的 Y 组合子`：在补充第二部分时不小心查到了一些奇妙的东西；简单研究了一下，就打开了新世界大门，而里面就是非常通用的手动实现函数式尾递归的途径，这或许就是函数式尾递归的本质；而这部分就是要 *用上一部分的方案介绍这个被发现的不得了的东西* 。***🦑谁要说 `((λ (s) (s s)) (λ (s) (s s)))` 不算奇迹，我就打爆他的不管什么头！！🦞🦞***


🐚🐚🦀

我这的函数式尾递归，其中「函数式」只是一种强调。一切值都是函数，普通值也只是无参返回自身的特殊函数，如此一来，尾递归也就不会产生压栈，而是只是把返回处的原本要调用的函数先作为值返回出来，然后再调用。于是效果上，尾递归在此时就好像一种更智能的 `GOTO` 一样了，你不需要指明跳回哪行，你只需要指明带着怎样的新的参数重新执行哪个已经定义过的函数——效果就是如此。

🐙🐙🐍

关于尾递归更多：

- 这篇写得不错，开头就直接地说到了重点：[浅谈尾递归 - SegmentFault 思否](https://segmentfault.com/a/1190000018153141)
- 也可以看这篇叫 [Learn You Some Erlang (LYSE)](https://learnyousomeerlang.com/) 的书。有[网页版](https://learnyousomeerlang.com/content)，里面介绍了[尾递归](https://learnyousomeerlang.com/recursion)。
  它是介绍 [Erlang](https://erlang.org/doc/index.html) （[快速开始](https://erlang.org/doc/getting_started/seq_prog.html)）的，所以顺便还学门语言😛。它很容易掌握，特别是如果你什么都不会的话。对于表达思路来说，它异常地简洁严谨实用（这是我的个人看法）。
  - 还可以顺带把 [LYAH](http://learnyouahaskell.com/) 也读了（[网页版目录](http://learnyouahaskell.com/chapters)）。我觉得这种书风格很有意思，值得学习。


上面那两本书推荐读网页版。网页上有个好处就是，便于翻译成母语。。。(•̀⌄•́)


## 为啥要尾递归？


相对于非尾递归，首先是众所周知的这个理由：

- 尾递归更省内存（也就是空间复杂度小）


相对于非尾递归，还有一个对我来说更重要的理由：

- 如果要人脑给函数传值跟着走一遍的话，我不需要把之前已经经过的调用都记着
  （其实还是空间复杂度的问题，只不过这次是对自己大脑的了）。


这里这个所谓的 *优化* 是有条件的。一般来说，返回处多次调用自己（这就好像树分了多个叉）的话，难度就会更大。（当然了如果全都作为值返回的话其实也就没必要优化了因为怎么也不会压栈）

另外，**多叉**的递归，可以很方便地被编译器优化为并发调度的计算。而且如果函数无副作用的话它也可以轻易地调度为分布式的计算。当然了，最大可达并发度不是固定的，空间复杂度也并不会减少。



相对于循环结构的话：

- 若用尾递归而不是循环，大脑不需要去记忆已经缩进了多少个层次，只需像设计流程图一样，把箭头指向它该指的地方就行（这是我使用 erlang 的体验）。至于，这到底是不是「循环结构」则**完全不必关心**的。  

- 若用尾递归而不是循环，对初学者来说会降低门槛，即便对熟练编程人员也有利于省去一些理论上可以省去的无用功从而解放大脑。因为，这样一来，需要记住的只有这两件事：即明白函数定义和函数调用都是在干啥，以及相关语法。
  之外的语法？关键字？理论上连使用的必要都没有了，**自然，也不需要在读代码的时候，要分出一部分精力来专门地匹配特定关键字**。因为，**不论你是否习惯这个工作，这部分操劳都是有办法避免的，最终做成的结果毕竟是完全一样的，那么多操劳的部分其实就是无用功了**。  
  既然如此，为何不避免呢？因为你在用的语言硬性要求你记住这些关键字并能时刻集中精神认出它们。所以在即便没必要集中更多精力的时候，也不得不集中更多精力，看完代码后才知道有没有必要，然后可能就会认为这儿应该有个注释。然而，有注释又能怎样？没有机器来约束注释的规范性的，如此，还要指望它成多达事儿吗？  

- 另外，若用尾递归而不是循环，先前循环中只得往注释里写的东西就可以写给函数名了。有啥用？注释里可是想写啥都成的啊！你以为你让人写注释人家就会写你认为有必要写在这的内容吗？而且，你认为，用没有标准规范的语言在注释里描述一遍业务逻辑、和用简明清晰还能被计算机解释的代码描述一遍业务逻辑，哪个更好？🙃  

- 主要就是代码本身的友善度了。。。  


## 为啥用 Erlang ？

本文大部分逻辑会使用 Erlang 代码实现。理由有下：

- 边界分明而且符号不多余。
  > 在 erlang 里，换行符是可以去掉的，这意味着压缩代码的逻辑会非常简单。而与此同时，它也并未使用太多多余的符号。
  
- 符号简洁且合理。
  > 从 Prolog 那儿来的 `, ` `; ` `. ` 的结尾符设计，让这个语言轻易就能明确地表达不同层次的内容；而函数定义的样板结构也已经达到了一种在简洁兼备一定表意性的同时有没有丢掉任何一块必要的部分。(有的语言会丢掉结尾符然后导致自己的缩进不得不具备语义——当然这是否是坏事也要看具体情况)
  
- 只需要定义和调用函数就能表述几乎任何逻辑流程。




# 🦑从递归到尾递归

这个部分会分别给出阶乘、斐波那契数列、从集合中过滤并懒取值的递归示例代码。每个示例都有尾递归和非尾递归两个版本，用于对照启发。

在下文中，[Tail]字样的部分可能就表示这是 *尾递归* 的示例，而[Tree]只要没有另外说明就是**单叉**的树递归。

（哦对了，前面提到的 LYSE 这本书里也有类似示例，而且比我的多。。。建议也去看看他写的这个，绝对值得收藏！： [recursive.erl](https://learnyousomeerlang.com/static/erlang/recursive.erl) ）

## 思路

其实就是一个技巧：

- 尽可能把一切都包揽在参数列表里！

多叉树我感性认识上不认为能优化成尾递归。而且有的时候也不见得这样优化是好的。不过我会再考虑和尝试。


## 案例

### 阶乘

这个是看 erlang 的 [guide](https://erlang.org/doc/getting_started/seq_prog.html#modules-and-functions) ([翻译版](https://zhuanlan.zhihu.com/p/28155407)) 的时候，由于脑袋转不动它本来的递归写法又觉得这个可以写尾递归，就为了方便思考而弄成了尾递归。

下面的代码会用 erlang 来写。它们都是能通过编译的，不过现在，您大可以不必关心什么语法不语法的。  
如果您知道，一个函数必然有这样的几个部分：

- 函数名
- 函数参数列表
- 函数体（里面要基于参数明确对返回的定义）
- 上面每个部分的起止标志

那么你就能够对下面的语法完成 *意会* 。如果不能，那就看上面的 guide （或者翻译版）好了，或者再前文提到的 LYSE 这本书。


#### Erlang - Tree  

```erlang
- module (recursion_tree) .
- export ([fac/1]) .

fac (0) -> 1 ;
fac (N) -> N * fac (N - 1) .

```

use:  

```erlang
c(recursion_tree). recursion_tree:fac(7). % ret: 5040
```

#### Erlang - Tail  

```erlang
- module (recursion_tail) .
- export ([fac/1]) .

fac (N) -> fac(N, 1) .

fac (0, FacRes) -> FacRes ;
fac (NumNeed, FacResPart) -> fac(NumNeed - 1, FacResPart * NumNeed) .

```

use:  

```erlang
c(recursion_tail). recursion_tail:fac(7). % ret: 5040
```

#### `%%%%`

关于普通递归到尾递归的转换，这或许是最简单的例子。

尾递归代码看起来似乎是可以定义更多信息的。

前面在【为啥要尾递归？】那部分提到的「更省脑」，此处也可以趁机检验一下，对比对比这两个逻辑哪个更费大脑空间。

> 尾递归的代码里，你不需要在调用后还得去记调用前的东西，忘掉就好，就当是船新的调用，**每一次都是第一次**。  
> 即便你真的要彻底亲自用脑子跑一遍这代码，也不是不能完成，即便代入的数很大。即便要在纸上写每一步，真的写写试试，应该也能体验到二者的区别。  
> 


### 斐波那契数列

#### Scheme

这个是当时看 SICP 的时候用 Scheme 写的。

功能只用 [Chez](https://cisco.github.io/ChezScheme/) ([cisco/chezscheme](https://github.com/cisco/chezscheme)) 测试过。

```scheme
#| some def |#
(define (=? a b) (= a b) )
(define (or? a b) (or a b) )

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;


#| tree invoke fib |#
(define (fib n)
        (if (or? (=? n 0) (=? n 1)) n
            (+ (fib (- n 1)) (fib (- n 2)))
        )
)

;; (fib 4) need:
;; |___(fib 3) need:
;; |   |___(fib 2) need:
;; |   |   |___(fib 1) = 1 <-:
;; |   |   |___(fib 0) = 0 <-:
;; |   |   = 1
;; |   |___(fib 1) = 1 <-:
;; |   = 2
;; |___(fib 2) need:
;;     |___(fib 1) = 1 <-:
;;     |___(fib 0) = 0 <-:
;;     = 1
;; = 3 ->:
;; 
;; tree rec


#| tail invoke fib |#
(define (fib n)
        (define (fib-iter next this step)
                (if (=? 0 step) this 
                    (fib-iter (+ next this) next (- step 1))
                )
        )
        (fib-iter 1 0 n)
)

;; (fib 4) same:
;; (fib-iter 1 0 4) same:
;; (fib-iter 1 1 3) same:
;; (fib-iter 2 1 2) same:
;; (fib-iter 3 2 1) same:
;; (fib-iter 5 3 0) = 3 <-: ->:
;; 
;; no-need-to-tree rec


#| desc desc |#

;; need: means, need to got the func value to get(=) the res.
;; same: means, same as. just while tail invoke can same as!
;; <-: get(=) the res without need: .
;; ->: whole func res.



#|-------------|#
;; end of file ;;
```
  

再用 erlang 试着写写

#### Erlang - Tree

```erlang
- module (recursion_tree) .
- export ([fib/1]) .
fib (0) -> 0 ;
fib (1) -> 1 ;
fib (NumOfIndex) -> fib(NumOfIndex - 1) + fib(NumOfIndex - 2) .
```

use:

```erlang
c(recursion_tree). 
recursion_tree:fib(7). % ret: 13
recursion_tree:fib(13). % ret: 233
```

#### Erlang - Tail

```erlang
- module (recursion_tail) .
- export ([fib/1]) .
fib (NumOfIndex) -> fib(0, 1, NumOfIndex) .

fib (ThisValue, _, 0) -> ThisValue ; % or better: fib (_, NextValue, 1) -> NextValue ;
fib (ThisValue, NextValue, RestStep) -> 
    fib(NextValue, NextValue + ThisValue, RestStep - 1) .
```

use:

```erlang
c(recursion_tail). 
recursion_tail:fib(7). % ret: 13
recursion_tail:fib(13). % ret: 233
```

#### `%%%%`

这里的数列是这样的： `[0 1 1 2 3 ...]`   
其中 Index 从 `0` 开始。

斐波那契数列的这个例子，看上去像是把二叉树递归转成了尾递归。
其实不能完全这么说。至少在我这，情况是这样的：**我重新使用了另一套思路**。

也就说，这块儿，我认为，也只能是说明，**尾递归能做到的效果也的确可以(但其实没啥必要)用树递归实现**，仅此而已了。。。

——不过它或许会成为一个不错的启发思路的案例：虽不能保证所有树递归都能改写为尾递归，但是应该能为「把某些即便不是单叉儿的树递归改为尾递归」的工作，提供一个或许还不错的启发。（至少对作者我来说是如此😬，如果这个能总结成一套通用的办法那就更好啦。）

### 列表按条件滤取

现在有数列 `[2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4]`   
希望能按这个顺序，从中取出前几个（ `2` 个/ `3` 个/ `99` 个）**奇**数。

#### Scala

如果用 Scala `(2.12.13)` 来实现，表意性最好的写法：

```scala
List(2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4).toStream.filter(_%2!=0).take(2).toList
```

不过想要验证这一点的话，就需要把 `filter` 算子的参数写成一个定义好的函数

```scala
def oddfilter (x: Int): Boolean = { println("filt: "+x) ; x%2!=0 } ;
List(2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4).toStream.filter(oddfilter).take(2).toList
```

可以在 repl 上看看：

```scala-repl
Welcome to Scala 2.12.13 (OpenJDK 64-Bit Server VM, Java 11.0.10).
Type in expressions for evaluation. Or try :help.

scala> def oddfilter (x: Int): Boolean = { println("filt: "+x) ; x%2!=0 } ;
oddfilter: (x: Int)Boolean

scala> List(2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4).toStream.filter(oddfilter).take(2).toList
filt: 2
filt: 1
filt: 3
res0: List[Int] = List(1, 3)

scala> List(2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4).toStream.filter(oddfilter).take(3).toList
filt: 2
filt: 1
filt: 3
filt: 0
filt: 9
res1: List[Int] = List(1, 3, 9)

scala> 
```

至于不用 Stream 是啥效果，可以自行试一下~ 😛

> 就是删掉 `.toStream` 再执行

上述实现来源：

- [Scala函数式编程（六） 懒加载与Stream](https://www.cnblogs.com/listenfwind/p/12707478.html)
- [Scala中Stream的应用场景及其实现原理](https://cuipengfei.me/blog/2014/10/23/scala-stream-application-scenario-and-how-its-implemented/)
​


> *不过作者，你好像还没体现出**尾递归**来呢！*
> 

没错，所以我再尝试用 erlang （只是我现在已经学会的部分）写一下。

为什么用 erlang 呢？因为我觉得写朴素的代码的话我这个语言是目前体验最爽的。

#### Erlang - Tree

```erlang
- module (recursion_tree) .
- export ([take_odds/2]) .

take_odds (_, 0) -> [] ; % like a `break` in loop code lang, but here is ret a val !!

take_odds ([ElementThis| RestElems], NeedTakeCount) 
    when ElementThis rem 2 =/= 0 
-> 
    [ElementThis| take_odds(RestElems, NeedTakeCount - 1)] ;

take_odds ([ElementThis| RestElems], NeedTakeCount) 
    when ElementThis rem 2 =:= 0 
-> 
    take_odds(RestElems, NeedTakeCount) ;

take_odds ([], _) -> [] .

```

use:

```erlang
c(recursion_tree). 
recursion_tree:take_odds([2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4],77). % ret: [1,3,9,1,7,1,1,7,1,9,1]
recursion_tree:take_odds([2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4],3). % ret: [1,3,9]
```

#### Erlang - Tail

```erlang
- module (recursion_tail) .
- export ([take_odds/2]) .

take_odds (List, HowManyNeedToTake) -> 
    take_odds(List, [], HowManyNeedToTake) .

take_odds (_, TakenRes, 0) -> TakenRes ;

take_odds ([ElementThis| OldListRest], NewList, NeedToTake) 
    when ElementThis rem 2 =/= 0 
-> 
    take_odds(OldListRest, [ElementThis| NewList], NeedToTake - 1) ;
take_odds ([ElementThis| OldListRest], NewList, NeedToTake) 
    when ElementThis rem 2 =:= 0 
-> 
    take_odds(OldListRest, NewList, NeedToTake) ;

take_odds ([], TakenResFew, _) -> TakenResFew .

```

use:

```erlang
c(recursion_tail). 
recursion_tail:take_odds([2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4],77). % ret: [1,9,1,7,1,1,7,1,9,3,1]
recursion_tail:take_odds([2,1,3,0, 9,1,7,1, 1,7,1,2, 9,1,8,4],3). % ret: [9,3,1]
```

#### `%%%%`

话说回来，要说含义逻辑上，其实那个树状递归更对味儿上一点。  

> 但尾递归的形式里可放进去的信息可以更多，所以还是后者牛逼。
> 



这个尾递归部分是我跟着 erlang guide 的 [More About Lists](https://erlang.org/doc/getting_started/seq_prog.html#more-about-lists) 部分 ([这是翻译](https://zhuanlan.zhihu.com/p/28194753)) 的 `reverse` 定义学的，所以结果也被倒序摆放了。。。

而且目前还没明白怎么让它结果在保持自然的情况下就是正着的。
另外，非尾递归的写法也是跟同一章节的 `convert_list_to_c` 定义学的，只不过用在了另外的需求。



> 另外，要记得这件小事：
> 
> 如果要在 erlang 里取余数（模）的话，
> 不要用百分号 `%` 而要用蕾姆 `rem` 。
> 
> `........`
> 
> 百分号 `%` 是注释。
> 在 erlang 要用蕾姆 `rem` 。
> 




# 🦑天才与爆栈！❄

这个部分会提供一个比阶乘更好一点的制造爆栈现象的办法。阶乘的结果实在太大了！

> 那天才是什么？那只是一个可爱的梗而已，不必在意！🙃🙃
> 

（而且其实，后来逐渐发现这个思路真的只是铺垫而已。要玩爆栈， `((λ (s) (s s)) (λ (s) (s s)))` 这个结构显然是最具有美感的：它又是彻底完成抽象的，又是彻底没做抽象的。。。抽象与具体在这里达到了辩证统一🙃🙃😝🤗）

## 办法

就是自制一个能完成 `模` 算数的函数。

> 这个做法其实是我玩 Bash 返回码的时候发现 `114514` 会被弄成别的数，二分法用 `(exit 2221);echo $?` 这样的样板摸了摸这个变与不变的底线后，发现规律有种递归的感觉，就在 Java 上实现了一个输入数字会给我对应 Bash 返回码的功能，结果就发现我可以灵活地输入大数小数来检测 Java 的允许的尾递归深度，于是就有了这么个办法。不过这是很早的事儿了。  
> 
> 有趣的是，直到最近，我才反应过来，这就是模法啊！！
> 是在看到这个的时候反应过来的：
> 
> ```elixir-shell
> iex> <<1>> === <<257>>
> true
> ```
> 
> 它来自[这个语言的官方手册的这里](https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html)。
> 


下面这段 Scheme 代码能表明我的想法。  
(如果你看不懂就说明你可以跳过它继续阅读)

```scheme
(define (remb num rem)
        (if (< num rem) num (remb (- num rem) rem) )
)
```

逻辑就是：

1. 有这么个叫 `remb` 的函数，输入两个参数 `num` 和 `rem` 的话:
2. 若是前者比较小函数就返回前者的值，要是不是这样那就前者减去后者作为新的 `num` 而后者继续做它的 `rem` **然后用这套新的参数重新调用一下这个函数**。


这样取模，**当然是十分低性能的**。所以，你不该用它真的去做什么计算任务。
它的价值仅仅在于，它的定义很简单，并且也可以轻易地通过使用不同的参数来**间接指定尾递归发生的次数**。


而这个检验就会引出来一个很了不起的想法：


> 能不能，在不支持尾递归的运行时上：
> 
> - **只是利用运行时本身提供的各种功能**
> - 而且**保持代码的样式上的尾递归形式的表达**
> 
> 来做到：
> 
> - **让不支持尾递归的运行时支持尾递归**
> 
> 这种事呢？
> 

答案是**能**。

下面会给出几个语言(运行时)运行这个检测逻辑的示例代码，**以及对应的 *令不支持者支持* 的代码**(目前只给出了 Bash 上的支持尾递归的技巧)。


## 冰雪聪明的天才算数器 ❄❄❄ 

这个是什么呢？这个其实并不是上面说的代码示例。

你可以跳过 *（虽然这么说有点残忍但这部分真的可以跳过）* ，不过如果你想放松一下心情，可以把这部分看完。

下面有请 `琪露诺` 老师讲话。

> 大家好，欢迎来到琪露诺的算术课堂。
> 
> 上面那个实现，想必大家都已经看到了：那里面并没有考虑 `num` 是负数的情况。
> 

**因为其实用不着**。

> 我当然知道，你以为我是笨蛋吗！哼！❄
> 总之，这样是不完美的！❄。
> 

> 琪露诺在这里要给大家带来一个加强版本，是一个完全可以叫做**天才算数器**工具！
> 
> 好，现在来看看琪露诺的伟大作品吧：
> 


⑨❄❄❄

```erlang
- module (playfuns) . 
- export ([remb/2, bakacal/1]) .

%% remb/2 define:
remb (Num, RemNum) 
    when 0 =< Num 
    andalso Num < RemNum 
-> 
    Num ;
remb (NumReming, RemNum) 
    when RemNum =< NumReming 
-> 
    remb(NumReming - RemNum, RemNum) ;
remb (NumReming, RemNum) 
    when NumReming < 0
-> 
    remb(NumReming + RemNum, RemNum) .

%% bakacal/1 define:
bakacal (N) -> remb(N - 1, 9) + 1 .
% bakacal (N + 1) -> remb(N, 9) + 1 . % error, illegal pattern

```

> 上面的 `bakacal` 就是 *天才算数器* 了。后面的 `/1` 则表示只需要一个参数就够了。
> 
> 是不是非常简单？(•̀⌄•́)
> 


> 接下来，如果想使用天才算术器，只需要在 Eshell 上这样做就行：
> 

```erlang-shell
1>c(playfuns).
{ok,playfuns}
2> playfuns:bakacal(10).
1
3> playfuns:bakacal(11).
2
4> playfuns:bakacal(9). 
9
5> playfuns:bakacal(8).
8
6> playfuns:bakacal(0).
9
7> playfuns:bakacal(-1). 
8
8> playfuns:bakacal(-2).
7
9> 
```

> 看！这么多示例，她都能算出恰当的结果来！！
> 
> 而且内部走的逻辑也美妙地统一着！
> 
> **善于总结统一的规律这才叫智慧嘛！！！！❄❄❄❄**
> 

> 这个可怜的算数器，明明是天才，却哪里都不受用，还要被人嘲笑“哈哈哈哈你只会数到九吗”。然而，谁又知道，人家背后精巧美丽的智慧呢？
> 可想而知！被笨蛋嘲笑只会数到⑨的时候，这个算数器是多么地心酸！！！！明明是你想让它只数到几它就能只数到几。。。。
> 
> 总之它是最强的！
> 


## 检验尾递归情况的各语言示例

继续说正事，检验尾递归。🐍

再次强调一下，**用它做模是低性能的**。

下面是示例。

### Scheme - `Chez - 9.5.4`

```scheme
(define (rb num rem)
        (if (< num rem) 
            num 
            (rb (- num rem) rem) 
        )
)
;; (rb 3333333333 2) ;; ret: 1
```

> 这儿一开始中间那里写错了，应该是 `(< num rem)` 被我写成了 `(num < rem)` 。。。
> 

话说 Chez 算得还真快。。。用 Racket 就能明显对比出速度差距。
这里主要的耗时，估计是加法的执行那里。


### Python :: `3.9.2, GCC 10.2.1`

```python
def rb (num, rem):
    if (num < rem): return num
    else: return rb(num - rem, rem)

### rb(3,2) # ret: 1
### rb(3333333,2) # err: RecursionError: maximum recursion depth exceeded in comparison
```

Python 在 REPL 上定义函数应该需要在最后多打几下换行。毕竟 *游标卡尺语言* 最大的问题其实就是木得结束标记。。。

#### Hy 试探

在 Python 上有个库叫 `hy` ，而它据说是一种 Lisp 。

一般来说， Hy 的定义要这么写（[参考](https://docs.hylang.org/en/alpha/tutorial.html#functions-classes-and-modules)）：

```hy
(defn remb [num rem]
  (if (< num rem) num (remb (- num rem) rem) )
)
```

尝试用用看：

```hy-repl
=> (remb 4 2)
0
=> (remb 5 2)
1
=> (remb 3333333 2)
Traceback (most recent call last):
  File "stdin-c205eccd9236cc55bd83a0f3cdcf9af3deb02b56", line 1, in <module>
    (remb 3333333 2)
  File "stdin-97ee98165e108d7d2747d4e423030117a0891754", line 2, in remb
    (if (< num rem) num (remb (- num rem) rem) )
  File "stdin-97ee98165e108d7d2747d4e423030117a0891754", line 2, in remb
    (if (< num rem) num (remb (- num rem) rem) )
  File "stdin-97ee98165e108d7d2747d4e423030117a0891754", line 2, in remb
    (if (< num rem) num (remb (- num rem) rem) )
  [Previous line repeated 986 more times]
RecursionError: maximum recursion depth exceeded in comparison
```

啊？！不是说有尾递归支持吗？我记错了？

找了找，找到了[这个](https://docs.hylang.org/en/alpha/api.html#module-hy.contrib.loop)：大体意思就是，他们是用宏实现的，要用上这几个好像关键字一样的东西。它下面有个阶乘的例子我这就不引用了，我一边出错一边模仿着，写了一个自制模的实现：

```hy
(defn rbloop [num_in rem_in]
  (loop [[num num_in] [rem rem_in]]
    (if (< num rem) num (recur (- num rem) rem) )
  )
)
;; (rbloop 33333 2) ;; ret: 1
```

这个 `loop` 后面的中括号里，有两个中括号，每个中括号里，左边那个是 `loop` 内会用的变量名，右边是给它第一次调用的传值。
就是说，在 Hy 里写 *尾递归* 的话，就必然要把**尾递归结构定义在函数内部**。

。。。我觉得这其实就是糖了个循环了嘛。。。

速度的话，试了一下，那个长数字真的是好久都没出来，所以就取消了。

#### Py 试探

我不会 Python ，目前查到的有这两种办法：

- [Python开启尾递归优化! - SegmentFault 思否](https://segmentfault.com/a/1190000007641519)  
- [记一种避免 Python 递归溢出的方法](https://zhuanlan.zhihu.com/p/37060182)  

对于二者：

- 前一篇是利用 Python 的语言特性做到的，一个叫装饰器的东西；  
- 后一篇是通过一个叫 Y 组合子 (Y combinator) 的途径去解决的，这个办法应该适用于一切只要是能把函数做值传递的语言。根据第二个链接里的描述它大概就是：把函数作为值传出，**从而在不开始里头函数调用的情况下完成对外头这个函数的调用**，从而手动避免函数内调用函数时产生压栈，然后再调用被传出的那个函数，如此往复。  


> 另外多说一句，这个 Python 文章真的到处都是啊。。。这里第二个链接还是我给下面 Powershell 写尾递归找方案的时候给搜到的。。。。
> 


### Scala :: `2.12.13, OpenJDK Java 11.0.10`

```scala
def rb (num: Long, rem: Long)
: Long = 
{
    if (num < rem) num 
    else rb(num - rem, rem) 
} ;

// rb(3,2) // ret: res1: Long = 1
// rb(3333333333L,2) // res2: Long = 1
```

虽然 Scala 其实是无限尾递归也不会有栈溢出，但它仍然是调用函数会压栈的（树递归会栈溢出）（这个版本）。

在这方面或许同一般的（哪怕是不纯的）函数式语言的标准不太相符。
一般的函数式标准应该是没有（或者是总能相当于没有）压栈这一说的，从而即便是树递归也都不会有所谓栈溢出了。（应该只有会不会耗尽被分配到的内存这一说吧）

不过 Scala 那个长数字的速度和 Chez 倒是能不相上下。

**而且，用更大的数字的话 Scala 会更胜一筹。**

> 我是在 Scala REPL 里用 `rb(9333333333L,2)` ，和 Chez 解释器里用 `(rb 9333333333 2)` ，来做的对比。
> 

这个 Scala 还是我在 Feodra 的 Wsl(1) 里用 `dnf` 直接安的。它用得是 OpenJDK ，还不是 GraalVM 。据说后者比前者还要快。

`JVM 的速度确实蛮不错的.jpg` （2021-06-12）

### Java :: `Jshell - 11.0.11`

```java
Long rb (Long num, Long rem)
{
    if (num < rem) return num ;
    else return rb(num - rem, rem) ;
}

// rb(3L,2L) // ret: $1 ==> 1
// rb(33333L,2L) // ret: $2 ==> 1
// rb(333333L,2L) // err: java.lang.StackOverflowError
```

这个 Jshell 是 GraalVM 里的。

如果在这直接定义的函数有 `static` 修饰符，就会得到这样的警告：

- `修饰符 'static' 不允许在顶级声明中使用, 已忽略`

不过函数仍可成功创建。

当然，即便是 Java11 即便是 GraalVM 又即便是 Jshell 这样新的东西，也都会栈溢出。

它应该能就是这样设计的，也有可能在哪有个开关，我没开开。

不过 Java 据说有一套办法，可以让它做到类似尾递归的效果。感兴趣可以自己看看的：

- [Tail Recursion in JAVA 8](https://blog.knoldus.com/tail-recursion-in-java-8/)

### Erlang :: `Erlang/OTP 24, Eshell V12.0, Windows-Version`

```erlang
rb (Num, Rem) when Num < Rem -> 
    Num ;
rb (Num, Rem) -> 
    rb (Num - Rem, Rem) .

%% c(xxx). xxx:rb(3,2). % ret: 1
%% c(xxx). xxx:rb(3333333333,2). % ret: 1
```

> 模块头部请自己补充。
> 


> 比上面的天才算术器具代码少了不少？
> 因为这里没管负数，而且变量名这儿也没写太长，仅此而已。🙂
> 

这里的长数字计算速度比 Chez 和 Scala 慢一点点。

如果**只是**在 erlang shell 上，则要写匿名函数。需要多一个参数。

```erlang
Rb = fun (N, R) -> 
    RbIter = fun 
        (N, R, _) when N < R -> N ; 
        (N, R, F) -> F(N - R, R, F) end , 
    RbIter(N, R, RbIter) end . 

%% Rb(3,2). % ret: 1
%% Rb(3333333333,2). % ret: 1
```

> 一开始匿名函数语法写错了，在 Eshell 上测来测去，根据提示信息发现，之前手机手写的代码简直比伪代码还伪代码，这里那里都丢三落四的。。。。😓
> 

速度的话，那个长数字，在 Eshell 用匿名函数，算了好久。。。

### Bash :: `5.0.17, x86_64-redhat-linux-gnu`

#### Bash Function

```bash
rb ()
{
    num="$1" rem="$2" &&
    ((num < rem)) && 
        { echo "$num" ; } ||
        { rb "$((num - rem))" "$rem" ; } ;
} ;
## rb 3 2 # out: 1
## rb 33333 2 # exit... no out no err, just exit after few sec. ...
```

> 为了避免很多问题，在 Bash 上尽可能地显式把能写的都写上就成了我写 Bash 的原则。
> 

这里把标准输出视为穿出数据的手段，而不是使用返回。

。。要说脆还是 Bash 脆，不大个数就完蛋掉了，啥也没有直接在等了一两秒后退了出来。。。

#### Bash Script File

这里我会直接用上 `exec` 。

```bash
#! /bin/bash

num="$1" rem="$2" &&

((num < rem)) && 
{
    echo "$num" ;
} ||
{
    exec /bin/bash "$0" "$((num - rem))" "$rem" ;
} ;

## bash trc.sh 3 2 # out: 1
## bash trc.sh 33333 2 # out: 1
```

这里大家可以自行检验一下，有 `exec` 和没有 `exec` 的区别。**建议用不那么重要的机器检验不然出啥事别赖我**。

> 脚本里面的格式化风格和前面不太一样。没有特别的原因，实际用哪个都好，我只是换换口味😐。（说实话脚本里下面那个分支还是这样写清楚一点的。。。）
> 

当然该慢还是慢。估计主要还是因为这个 `((xx+xx))` 慢。虽然最后能出来数，但真的慢。

#### `cd` 的奇迹之 Script File ！

其实，如果只是测测 Bash 有没有 `exec` 的区别的话，完全可以用下面这个：

```bash
#! /bin/bash

dir0="${1:-0}" &&

cd $dir0 &&
{ pwd ; } ||
{
    exec /bin/bash "$0" "$((dir0 + 1))" ;
} ;

## bash cdtr.sh # err: cdtr.sh: line 5: cd: (some num will be here): No such file or directory
```

它被执行的话，会一直报错找不到几几几文件夹，你就可以用这个来判断递归了多少次了：

- 把那个 `exec` 删掉的话，这个脚本根本走不了多远就会出现 *一些问题* ；
- 有 `exec` 的话，就会看到数字一直涨下去，没完没了，除非你在它数字到那么多之前建立一个名为更大数字的文件夹，那么等它试错到这儿就会走到那个文件夹里并 `pwd` 。

在 Bash 上用这样的递归脚本，可以很直观地进行一些试错的工作：执行一个命令，错了重试，对了才不重试。（或者反过来？？）

#### `cd` 的奇迹之 Function ！

上面其实是利用了 `exec` 的一个特性：**它会抛弃它所在文本上下的命令，它之后的命令不论如何也都不会执行了。**（当然这仅限于此处对 `exec` 的用法）

基于这，*还有一些其他的乱七八糟的思路*，我终于找到了： ***不生成文件就能达到尾递归效果的办法*** ！！

> 赞美吧！！！！

简单示例：

```bash
tailcd ()
{
    count=${1:-0} &&
    cd $count ;
    exec bash -c "$(declare -f tailcd)"' ; tailcd '"$((count+1))" ;
} ;
## run:
bash -c "$(declare -f tailcd)"' ; tailcd'
```

或者像下面这样其实更好：

```bash
tailcd ()
{
    count=${1:-0} &&
    cd $count ;
    exec bash -c 'tailcd '"$((count+1))" ;
} &&
export -f tailcd ;
## you can run,
`# use this:`  bash -c tailcd
`# or this:`  (tailcd)
```

> 上面的代码支持简单的压缩逻辑：你可以只是，把换行替换成空格、再把连续空格删成一个。这样之后代码仍能执行。
> 

执行的话，这里建议不要直接执行 `tailcd` 这样地调用函数。
最简单的写法也得是有那对小括号的写法： `(tailcd)` 。

直接执行 `tailcd` 也不是说不行，你可以试试，就是它停止运行后你可能会感到不爽。

> 怎么个不爽法？自己试试就知道了。兴许还能涨经验呢！ `:D`
> （其实就是个进程树的事儿。不论 bash -c tailcd 还是  (tailcd) 都是为了开子进程。为何要开子进程？这就需要你自行研究一下 `exec` 啦！）
> 


这样一来，前面没成功的就可以不用写文件啦！！

#### Bash Function

为什么我这么着迷在 Bash 上用 `function` 而不是脚本文件呢？

很重要的一个原因就是，定义函数的话，我就可以很放心地确定这两件事：

- 它不会被乱改，它就是我定义的样子，而且我轻易就可以用新定义覆盖而不跟磁盘交互。
- 它的生命周期是明确的，它的影响范围是有限的，我不希望一个软件的一部分会突然出现在一个地方而若我不管则它就不会被清理。


```bash
rbex ()
{
    num="$1" rem="$2" &&
    ((num < rem)) && 
        { echo "$num" ; } ||
        { exec bash -c "$(declare -f rbex)""$(echo ';' rbex  $((num - rem))  $rem)" ; } ;
} ;
## bash -c "$(declare -f rbex)"'; rbex 3 2' # out: 1
```

上面算是朴素地展示一下思路。下面会更省资源一点：

```bash
rbex ()
{
    num="$1" rem="$2" &&
    ((num < rem)) && 
        { echo "$num" ; } ||
        { exec bash -c "$(echo  rbex  $((num - rem))  $rem)" ; } ;
} &&
export -f rbex ;
## bash -c 'rbex 3 2' # out: 1
## echo rbex 3 2 | bash # out: 1
## echo rbex 33333 2 | bash # will out 1 , but slow ...
## (rbex 3 2) # out: 1
## (rbex 128 2) # out: 0
```

> 尾递归处的 `bash -c "$(echo  rbex  $((num - rem))  $rem)"` ，等同于：
>  `bash -c rbex' '$((num - rem))' '$rem` 这样写的效果。  
> 


> 前者的空格会被视为分隔符而自动变成一个。这使得我可以用前者的形式无所谓连着多少空格而给 `bash -c` 的内容总能一致。  
> 

这里的小道理：

- 通过在 `bash -c` 里调用函数，来让函数也能被 `exec` 作用到。
- 我先想到了可以用打印函数整体的 "$(declare -f rbex)" 把外面的函数定义交给 `bash -c` 后面的命令们。
- 然而又想到既然是 *子进程* 那么我只需要 *全局化我定义的函数* 不就行了吗？用 `export -f rbex` 的话当前进程的子进程里它就都不会失效了。

这样一来：

- 被定义的逻辑能一直存在：这是能被 `exec` 作用的前提；
- 这个一直存在的定义的生命周期是合理的， ***该销毁时就销毁、不该销毁时就不销毁*** ；

这两点就得以都满足了。

> 另外，这里参数都是**不包含空格的**数字，所以才不必写成 `"$((num - rem))"` 这样或者 `"'""$((num - rem))""'"` 这样的。
> 不过，作为一个整体，还是该在 `"` 里在 `"` 里该在 `'` 里在 `'` 里的话，能严谨一点。比如，**上面的示例如果传入内容带空格的参数，*那我也不知道会发生什么***。
> 若确信可能包含空格，则必须有引号把一个整体明示为一个整体了。这里不多讨论，请**自行增加必要的单双引号并经过测试**。
> 


调用示例多给了几个写法，可以自行思考为啥能这么写并选用合适于自己的写法。
（应该不会有谁这么闲得慌用 Bash 开发东西就是了。。。🐌）

**比较推荐小括号那个写法。因为简洁。**
而且，小括号的话，**你看它是不是非常眼熟！！还记得 Scheme 吗！**
（其实这应该也不是啥大不了的事儿，因为只是像而已。目前我并不能保证用这个套路就能在 Bash 上实现一套 Lisp 。。。。不过谁敢兴趣可以试试）🐍


### Powershell :: `7.1.3`

```powershell
function Rem-B
([int]$Num, [int]$Rem)
{
    if ($Num -lt $Rem) { return $Num }
    else { return Rem-B -Num ($Num - $Rem) -Rem $Rem }
} ;
## Rem-B 3 2 # ret: 1
## Rem-B 4 2 # ret: 0
## Rem-B 33333 2 # err: InvalidOperation: The script failed due to call depth overflow.
```

可见加了 `return` 打断也是没用的。

不过，它既然有管道，那咱弄弄试试：

```powershell
function Rem-B
{
    process 
    {
        $Num = $_[0] ; $Rem = $_[1] ; 
        if ($Num -lt $Rem) { ,($Num,$Rem) }
        else { ,(($Num - $Rem),$Rem) }
    }
} ;
## ,(3,2) | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B # out: 1\n2
## ,(4,2) | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B # out: 0\n2
## ,(33333,2) | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B | Rem-B # out: 33123\n2
```

。。。。

我为啥这样弄呢？

递归着管道的话光是 `,(3,2)` 就出不来。

这部分还要再研究下。另外，在[一些 Y 组合子的文章](https://zhuanlan.zhihu.com/p/262284625)里也见到了类似的结构。



# 🦑无穷无尽的 Y 组合子

这个部分尝试介绍最近刚刚弄明白的一个玩意： *Y 组合子* （ *Y combinator* ）。

关于 Y combinator 的扩展阅读：

- [从零开始理解 Y 组合子 — » Functor](https://www.functor.me/post/programming/y-combinator)  
- [Y Combinator - bajdcc - 博客园](https://www.cnblogs.com/bajdcc/p/5757410.html)  
- [Y组合子（Y Combinator）| The Little Schemer 第九章 - 知乎](https://zhuanlan.zhihu.com/p/262284625)  
- [函数式编程中的Y组合子 | 传不习乎](https://oychao.github.io/2018/10/23/javascript/37_y_combinator/)  
- [Python lambda实现Y组合子 - 马車同学](https://jijing.site/sicp/python-fp.html)  


以及两个对一本好书的翻译 (对扩展阅读的扩展阅读) ：

- [The Little Schemer 中文版 | Lazy_Pig](https://uternet.github.io/TLS/)  
- [《The Little Schemer》笔记 1.0 文档](https://the-little-schemer.readthedocs.io/zh_CN/latest/index.html#)  



## 前情提要

上面介绍 `Remb` `/` `rb` 那一章，补充内容期间阴差阳错查到了 *Y 组合子* 这么个东西。

仔细看了看，我觉得这就是尾递归不压栈设计的本质。

不过这个组合子好像也只是用来想办法让匿名函数能调用自己的呢。。。

我用 Erlang 的匿名函数实现了一个可在 Eshell 上用的 `RemB` ，它速度比起前一章的匿名函数写法也会快很多。

当然，这里用 Erlang 的目的还是在于它的表达便于初步了解计算思路。

## 试探试探左脚踩右脚上天

下面的部分应该是 *Y 组合子* 相关知识里比较好理解的部分。

不过还并没出现 *Y 组合子* 本身，而只是用一种比较笨的办法让无名函数（无名函数是值）调用自身。

### Erlang :: `Erlang/OTP 24, Eshell V12.0, Windows-Version`

先不遵循 *lambda 演算* 的原则，这里定义的匿名函数都会先绑定变量名。

（这不是函数名。函数无名，只是值而已。这里只是给值绑定了名称。不过调用的写法跟一般函数一样）

```erlang-shell
RembNourisherInsideRemb =
    fun (FuncNourisherInsideFunc) ->
        fun (Num, Rem) when Num < Rem -> Num ;
            (Num, Rem) when Num >= Rem -> 
                FuncGotWithFuncNourisher = FuncNourisherInsideFunc(FuncNourisherInsideFunc) , 
                FuncGotWithFuncNourisher(Num - Rem, Rem) 
        end 
    end , RemB = RembNourisherInsideRemb(RembNourisherInsideRemb) .

RemB(3,2). % ret: 1
RemB(333333,2). % ret: 1
RemB(333333,669). % ret: 171
333333 rem 669. % ret: 171

```

Erlang 不支持柯里化写法，也就是 `FuncE(FuncE)(X)` 这种写法，必须先 `Func = FuncE(FuncE)` 然后再 `Func(X)` 才行。

不过没关系，其实就是少一副括号的问题。后面会给出不用变量名的写法。

### Scheme :: `Chez - 9.5.4`

下面就要开始 [*让 lambda 演算放飞自我*](https://picasso250.github.io/2015/03/31/reinvent-y.html) 的不给匿名函数绑定变量名的写法：  

> 不熟悉吗？看看下面的写法就熟悉了：
> 
> ```scheme
> (+ 1 1) ;; ret: 2
> (+ 1 1 1) ;; ret: 3
> ([lambda (x) (+ 1 1 x)] 3) ;; ret: 5
> ([lambda (x y) (+ x y)] 3 4) ;; ret: 7
> ([lambda (a x y) (+ x y)] + 3 4) ;; ret: 7
> ```
> 
> 分号后面的是注释，我把分号前面的式子的执行结果写在注释里了，当然最好还是自己执行以下试试看。  
> 从简单到复杂，自己写一遍，执行一下看看，并为触发错误感到信息，因为这就是进步的空间。  
> 
> Scheme 是一个 Lisp 方言，它前后有括号明确边界，中间有空格明确划分，所以用起来极为灵活。
> 可以在空格的地方随便换行，连续任何多个空格换行等空白符在语义上是完全一样的。
> 


```scheme
(
    [lambda (func-nourisher-inside-func)
        [lambda (num rem)
            (if (< num rem) num 
                ((func-nourisher-inside-func func-nourisher-inside-func) (- num rem) rem)
            )
        ]
    ]
    
    [lambda (func-nourisher-inside-func)
        [lambda (num rem)
            (if (< num rem) num 
                ((func-nourisher-inside-func func-nourisher-inside-func) (- num rem) rem)
            )
        ]
    ]
)
```

好了。

上面这一整坨，它有上下两小坨。仔细看下，二者完全一样。  
外面再括一个括号，这就是做了之前的 `FuncGotWithFuncNourisher = FuncNourisherInsideFunc(FuncNourisherInsideFunc)` 的等号右边的工作。

也就是，下面那坨是参数，被代入了上面那坨，上面那坨在它所在的一对圆括号里，被调用了，参数就是下面那坨。

顺便也可以这样写：

```scheme
(
    [lambda (be-nourishering)
        (be-nourishering be-nourishering)
    ]
    
    [lambda (func-nourisher-inside-func)
        [lambda (num rem)
            (if (< num rem) num 
                ((func-nourisher-inside-func func-nourisher-inside-func) (- num rem) rem)
            )
        ]
    ]
)
```

如果这个办法用给 Erlang 的话，应该也不需要使用变量名了。毕竟，虽然 `fun (X,Y) -> fun (Z) -> X+Y-Z end end(1,2)(4).` 在 Erlang 不合法（在 Python 或 Scala 里则可以这样写），但 `(fun (X,Y) -> fun (Z) -> X+Y-Z end end(1,2))(4).` 则是可以得到预期结果的语法正确写法，就像 `fun (X,Y) -> X+Y end(1,2).` 这样写完全不会有问题一样。



使用的话，就是这样使用——匿名函数的定义本身就当函数名使用：

```scheme
((
    [lambda (func-nourisher-inside-func)
        [lambda (num rem)
            (if (< num rem) num 
                ((func-nourisher-inside-func func-nourisher-inside-func) (- num rem) rem)
            )
        ]
    ]
    
    [lambda (func-nourisher-inside-func)
        [lambda (num rem)
            (if (< num rem) num 
                ((func-nourisher-inside-func func-nourisher-inside-func) (- num rem) rem)
            )
        ]
    ]
) 3 2 )
```

或者：

```scheme
((
    [lambda (be-nourishering)
        (be-nourishering be-nourishering)
    ]
    
    [lambda (func-nourisher-inside-func)
        [lambda (num rem)
            (if (< num rem) num 
                ((func-nourisher-inside-func func-nourisher-inside-func) (- num rem) rem)
            )
        ]
    ]
) 3 2 )
```

返回结果是 `1` 。

> 上面格式化的原则是，一对括号务必上下对齐或左右对齐。不会发生调用的部分 (即只是定义内容的部分) 用中括号，会的用圆括号 (语法上随便用啥括号都是行的) 。中括号里视情况前几项不要换行，区分定义的头和身。  
> 有的说法认为人不该数括号。我同意。所以，括号才不该在最尾巴。虽然那样是看着简单，但那也失去了括号的作用了啊。 Scheme 的 S 表达式令这个语言足够灵活又严谨，这是它的优点，那就要充分发挥出来才行。  
> 
> 当然，调用示例增加的部分字符特地没有这样格式化。主要是我懒，而且新增的部分也很简单，所以我觉得也就没必要了。  
> 


### 尚有不足

上面的这些做法，在[王垠的这个幻灯](http://www.slideshare.net/yinwang0/reinventing-the-ycombinator)（[不一定能访问的快照](http://cncc.bingj.com/cache.aspx?q=yinwang0+ycombinator&d=4883850478881867&mkt=zh-CN&setlang=zh-CN&w=RWu7IZBVG7qs61cyeT2mdIqaPMCbmjp8)）里被叫做 `poor man's Y` 🙃（当然这也有可能是王的某天才老师这么叫）。

如果把 *函数定义* 视为 *确定的值* 、而 *函数调用* 视为 *不确定的值* 的话，并且又假设 ***不确定的值一定会导致多压栈*** 的话，那么，上述就显然是不够的。

所以，现在这个逻辑其实还不能算完成了当初的目的：毕竟这里的目的并非只是让匿名函数能尾递归而已。


## 继续前进

先搞一个更通用的 Y 组合子吧。

从 [`纸木城` 的这篇文章](https://zhuanlan.zhihu.com/p/262284625)可以看到一套不错的推导。

搜来搜去，包括[王垠那个 PPT](http://www.slideshare.net/yinwang0/reinventing-the-ycombinator) ，大体都是做了这几件事：

- 搞一个 `poor man's Y`
- 抽象看起来重复的部分 (用 `lambda` )
- 让 `目标函数内部的目标函数生成器` (`func-nourisher-inside-func`) 通过传入具体逻辑块生效 (生效即指发生调用)
- 把 `func-nourisher-inside-func` 部分自己弄成单独一块然后递归部位传入它里面它才生效 (即发生调用)

下面代码的标识符，来源于这个漫画作品：

[![my-beautifulist-chiyo-sis](https://img.moegirl.org.cn/common/b/b0/My_Elder_Sister_02.jpg)](https://zh.moegirl.org.cn/File:My_Elder_Sister_02.jpg)

来自萌娘百科的页面： `https://zh.moegirl.org.cn/%E5%8D%83%E5%A4%9C(%E5%A7%90%E5%A7%90)`

🦎

下面整一个 `remb` 用这种写法实现的示例吧！（并附我的讲解）这回，先用 Scheme 再用 Erlang 。因为匿名函数似乎 S 表达式是最直观的。

### Scheme :: `Chez - 9.5.4`

这部分仍然用 Chez 实现，即便它没有别的 Scheme 实现用起来便利，比如要用模式匹配的话。因为我觉得它是个非常简练且天才的 Scheme 实现，所以决定仍用 Chez ，跑不通就看官方文档呗 (反正我已经翻译好并离线了一份了🐉) 。


> 下面的代码风格，只是我自认为，它便于，即便是人类的视觉能力，也能轻松辅助理解代码。因为我觉得这样是层次明确的，而不是边界不明的。  
> 我不保证它总能有利于任何人的思维习惯。所以，如果你不习惯的话，则还是最好自行格式化成令你感到舒适的样子。🐚  
> 


```scheme
(
    (
        [lambda (koyuu)
            (
                [lambda (umareru)
                    (umareru umareru)
                ]
                
                [lambda (chiyo)
                    (
                        koyuu
                        
                        [lambda (pakotte)
                            ((chiyo chiyo) pakotte)
                        ]
                    )
                ]
            )
        ]
        
        [lambda (chiyo-oma)
            [lambda (pako-bako)
                (record-case pako-bako
                    [(remb) (num rem)
                        (if (< num rem) num
                            (chiyo-oma [list 'remb (- num rem) rem])
                        )
                    ]
                )
            ]
        ]
    )
    
    '[remb 3 2]
)
```

调用的话需要只是传一个参数。我用了 `record-case` ，所以这个被传入的列表的第一项也必须是一个原子或者说符号类型的变量，这里我自然就用了 `remb` 这个名称。

大概 Chez 上用 *模式匹配* 貌似就是必须这样用了。
—— 这个也不一定，我也只是在一两小时以内匆匆忙忙查着 Chez 的文档然后搞定了代码。（为啥这么匆匆忙忙？因为敲定了上面变量名后我实在是太感到激动人心了。。。。🐚🐚🦑🦑）  


> 另外，如果你熟悉上面提到的那本漫画，特别是它的 `里本` 的话，你会发现，上面的代码的命名大概会对你理解各个匿名函数之间的关系有不小的帮助作用。。。。  
> ——不懂我在说啥，说明你是一个朴实健康的乖孩子，那么忽略这段即可。当然你也可以做一个富有探索精神的棒孩子，在这之前请做好兴高采烈地直面深渊的觉悟。🙃  
> 
> (说笑，说笑……)  
> 

🐍

上面的原本是 *尾递归* 的代码里，在关键的递归发生部位，实质上只是传入了无需递归即得出的确定值。如果能够传入两个参数，即需要前面是 `((chiyo chiyo) pako1mata pako2mata)` ，那也只是 `chiyo-oma` 被怼了两个确定的值进去了，仅此而已。

> 可见实现真正的尾递归还得依靠千夜姐姐 .... 🦀🦀  
> 千夜姐姐是最棒的了！ ... 🦀🦀  
> 


最后附上一个 Racket （ `v7.9 [cs]` ）上的实现与使用：

```racket
(
    (
        [lambda (koyuu)
            (
                [lambda (umareru)
                    (umareru umareru)
                ]
                
                [lambda (chiyo)
                    (
                        koyuu
                        
                        [lambda (pakotte)
                            ((chiyo chiyo) pakotte)
                        ]
                    )
                ]
            )
        ]
        
        [lambda (chiyo-oma)
            [lambda (pako-bako)
                (match pako-bako
                    [(list num rem)
                        (if (< num rem) num
                            (chiyo-oma [list (- num rem) rem])
                        )
                    ]
                )
            ]
        ]
    )
    
    '[333333 669]
)
; ret: 171
```

模式匹配其实就是为了便于把参数列表 `pako-bako` 拆开而已。

简单说说这前前后后都是在干啥吧：

![pako-01](https://user-images.githubusercontent.com/68635334/124380842-ac3f7100-dcf1-11eb-8516-fd5744658516.png)
![pako-02](https://user-images.githubusercontent.com/68635334/124380844-b06b8e80-dcf1-11eb-83f7-e2e9c07e426f.png)
![pako-03](https://user-images.githubusercontent.com/68635334/124380882-eb6dc200-dcf1-11eb-8f30-1b819854709e.png)
![pako-04](https://user-images.githubusercontent.com/68635334/124380852-b5c8d900-dcf1-11eb-92e6-a0e62461321f.png)
![pako-05](https://user-images.githubusercontent.com/68635334/124380853-b6616f80-dcf1-11eb-8b83-e396a29617d9.png)
![pako-06](https://user-images.githubusercontent.com/68635334/124380854-b6fa0600-dcf1-11eb-95c0-af37ebb9bf00.png)


试了下，下面这样，用中文字符作标识符的话，也能执行：

```racket
(
    (
        [lambda (含逻辑者)
            (
                [lambda (待生成者)
                    (待生成者 待生成者)
                ]
                
                [lambda (生成逻辑者)
                    (
                        含逻辑者
                        
                        [lambda (递归时行动参数)
                            ((生成逻辑者 生成逻辑者) 递归时行动参数)
                        ]
                    )
                ]
            )
        ]
        
        [lambda (行逻辑者)
            [lambda (行动参数)
                (match 行动参数
                    [(list num rem)
                        (if (< num rem) num
                            (行逻辑者 [list (- num rem) rem])
                        )
                    ]
                )
            ]
        ]
    )
    
    '[333333 669]
)
; ret: 171
```

这样似乎更明确了。

很明显的一个事实就是：在 lambda 演算里面，其实仍有命名；只不过是这样子的： `我的名字在你那、你的名字在我那；我需要的在你那、你需要的在我那` 。


> 像极了爱情 🦀
> 


### Erlang :: `Erlang/OTP 24, Eshell V12.0, Windows-Version`

有了上面的 Scheme 版本，写 Erlang 版本就好写了。

这里用 Erlang 也不赋值变量名。

上面方括号是定义（这是我自己给我自己的规范），圆括号是调用，那么在 Erlang 就是：把前面的圆括号挪下面、把函数名或被定义的匿名函数往左缩进、把 `]` 换成 `end` 把 `[lambda` 换成 `fun` 并注意定义头定义体之间有 `->` （简单说就是每个 `fun` 后面都得有一个 `->` ）、再去掉一下多余的括号并简单修补一下语法不合适的部分就好啦。

```erlang
(
    fun (KoYuu) ->
        fun (UmaReru) ->
            UmaReru(UmaReru)
        end
        (
            fun (ChiYo) ->
                KoYuu
                (    
                    fun (PakoTTe) ->
                        (ChiYo(ChiYo))(PakoTTe)
                    end
                )
            end
        )
    end
    (
        fun (ChiYo_OMa) ->
            fun ({Num, Rem}) when Num < Rem -> Num ;
                ({Num, Rem}) when Num >= Rem ->
                    ChiYo_OMa({Num - Rem, Rem})
            end
        end
    )
)
({333333, 669}) . % ret: 171
```

上面应该是没有一个多余的括号的。

柯里化的那个调用时的写法，就是 `fun(a,b)(c,d)` 这种写法，它好不好，见仁见智，我反正现在还说不清楚。无非是支持了就可以用吧。

不过我觉得，强制要求写成 `(fun(a,b))(c,d)` 这样，而不允许上面那样写，其实也不差。因为这样才真的强调了 *柯里化* 的本质：先传出来一个函数，再紧接着调用。


### Python :: `3.9.5, GCC 10.3.1`

从 Scheme 往 Python 改也蛮好改的。

在 Python 我就用 *中文变量名* 了。有搜到一个[不错的主张](https://zhuanlan.zhihu.com/p/363090247)：

> 一开始很希望之后的维护由他多出力，但感觉那时他的动力并不大。花个把礼拜做出了雏形，意外和惊喜的是，这位在九月二十八日就提交了这个 “照猫画虎”PR，并且之后持续改进，十月之后我除了合并 PR 之外基本没有投入其他精力。
> 可见中文命名对于鼓励新手参与开源项目的作用。
> 开源项目的基本架构搭建之后，如果项目本身使用的是中文命名，用户（往往非程序员）应该会更有动力去学习代码。并不是说英文命名肯定会阻止参与项目，但会让很大一部分人望而却步。
> 

我觉得说得挺有道理。

这是我一开始改出来的样子：

```python
(
    (
        (
            lambda 含逻辑者 :
            (
                (
                    lambda 待生成者 : 
                    (
                        待生成者(待生成者)
                    )
                )
                
                (
                    lambda 生成逻辑者 : 
                    (
                        (含逻辑者)
                        (
                            lambda *递归时行动参数 : 
                            (
                                生成逻辑者(生成逻辑者)(*递归时行动参数)
                            )
                        )
                    )
                )
            )
        )
        
        (
            lambda 行逻辑者 : 
            (
                lambda num,rem :
                (
                    num if (num < rem) 
                    else 行逻辑者(num - rem, rem)
                )
            )
        )
    )
    
    (333333, 669)
)
## ret: 171
```

在这里，为了确保可以不给名字就调用，匿名函数要被圆括号包起来。
然而，就是这个操作！这让 Python 又有了对定义结尾的明确标志！！

> 看到没！ Python 终于不是彻彻底底的 *游标卡尺语言* 啦！！！🍾🍾🥂🥂
> 谁再说狗头是彻彻底底的 *游标卡尺语言* ，你就可以像这样用一串串纯的 `lambda` 打爆他的 Python ！！
> 

🦉🦉🦉🦞🦞🦞🦔🦔🦔


而且，这么看来，虽然 Python 还没有 `match-case` ，但似乎可以用 `lambda` 来假装有的……至少拆包的能力是可以有的。但也只是拆参数列表而已。。。并不算拆包。

> 其实 `match-case` 在 Python 是有的，只是还没有。虽说是今年年初才被允许有了。  
> 查到[这个](https://www.kodyaz.com/python/python-match-case-statement-code-sample.aspx)和[这个](https://renanmf.com/python-match-case/)说，要到 `3.10` 才有。而现在 (`2021-07-03`) 官网最新正式版还是 `3.9.6` 。。。（我还专门试着更新了一下自己 WSL 里的 `python` ，仔细看会看到这部分我用的版本跟前文的就不一样了。。一点微妙的不一样。。）
> 

哦对了，上面那片代码，如果在 Python 里，很多空格是可以去掉的。不过相应的，调用的括号也不能离函数名太远（不能到下一行）。那么就可以有等价的写法：

```python
(
    lambda 含逻辑者 :
    (
        (
            lambda 待生成者 : 
            (
                待生成者(待生成者)
            )
        )   (
            lambda 生成逻辑者 : 
            (
                含逻辑者(
                    lambda *递归时行动参数 : 
                    (
                        生成逻辑者(生成逻辑者)(*递归时行动参数)
                    )    )
            )   )
    )
)   (
    lambda 行逻辑者 : 
    (
        lambda num,rem :
        (
            num if (num < rem) 
            else 行逻辑者(num - rem, rem)
        )
    )   )   (333333, 669) # ret: 171
```

还可以继续减少括号，但我觉得免了吧。再减少括号，我反正就看不出层次来了。

另外从这个化简，其实也能看出，像这种 `scalafun(args1)(args2)...` 的柯里化调用写法的本质是什么。

不过其实我们**本来的目的还没达成**，虽然这里成功地在 Python 里也用上了有头有尾的写法。

我们本来是想让 Python 可以尾递归的，现在如果把 `669` 换成 `1` 的话，你会被错误信息胡一脸的，我刚被胡了一脸。

~~`<!-- 至于原因明天再找（但这个有可能也会递归吧） -->`~~


借鉴了[前面有提到的这个链接](https://zhuanlan.zhihu.com/p/37060182)里的思路：

```python-repl
>>> r = (
...     lambda 含逻辑者 :
...     (
...         (
...             lambda 待生成者 :
...             (
...                 待生成者(待生成者)
...             )
...         )   (
...             lambda 生成逻辑者 :
...             (
...                 含逻辑者(
...                     lambda *递归时行动参数 :
...                     (
...                         lambda: 生成逻辑者(生成逻辑者)(*递归时行动参数) 
...                         #^# 这个部分就会传给外面的变量 r 
...                         #|# 所以下面调用（这就只是一次调用了）也是空括号 r() 
...                     )    )
...             )   )
...     )
... )   (
...     lambda 行逻辑者 :
...     (
...         lambda num,rem :
...         (
...             num if (num < rem)
...             else 行逻辑者(num - rem, rem)
...         )
...     )   )   (33333, 2)
>>> r
<function <lambda>.<locals>.<lambda>.<locals>.<lambda>.<locals>.<lambda> at 0x7f5215545ee0>
>>> r = r()
>>> r
<function <lambda>.<locals>.<lambda>.<locals>.<lambda>.<locals>.<lambda> at 0x7f5215545e50>
>>> while callable(r): r = r() #<-# 这部分相当于用 while 手动把每层递归都走一遍
...
>>> r
1
>>> 
```

这样就不会爆栈了。。。

所以。。。到头来在 Python 还是用了 Python 本身的循环啊。。。。🤢

> 破案了！ Python 是妥妥的命令式语言。
> 

不过 Python 这个命令式风格的语言倒蛮好玩的：可以这样折腾那样折腾，然而它还是它。。。

> 可惜，和千夜姐姐一起的行动不能够自动进行了。。。。😭本质上还是机器指令循环而已。。。千夜姐姐没了。。。可恶。。。。😭😭😭
> 


## 回响

现在来看，所谓 *Y 组合子* 其实就是想办法把一个能生成自己的生成器传到自己里面去，并且这个生成器生成的自己也自带生成自己的生成器。。。。好绕啊，总之还是通过递归来想办法保持一段信息在执行期间一直存在。

现在看来，之前在 `天才与爆栈！❄` 部分中提到过的用 `exec bash -c` 和 `"$(declare -f 函数名)"` 其实也是类似的道理，只不过， Bash 上的这个做法其实是更笨一些， *在前往没有定义的地方之前先拼接好一套定义的代码* 如此而已。

下面写一个示例，它能执行命令，并在出错后重试。打印信息的风格借鉴了 Erlang 的返回。

```bash
redoer () 
{
    cnt=${2:-0}  cmd="${1:-echo xargs-i is {}}" &&
    bash -c "$cmd" &&
    {
        echo \{ok, {}, $cnt\} ;
    } ||
    {
        echo \{err, {}, $cnt\} ;
        exec bash -c "$(declare -f redoer)""$(echo ' ; 
        ' redoer "'$cmd'" $((cnt+1)) )" ;
    } ;
} ;

```

上面就是定义了。使用示例可能优点麻烦，主要是因为我不能确定被批量填到 `{}` 位置的是什么。不过也没关系，相信你可以看懂。😘

这是一个应该能用的使用例。你会从错误信息里看到，某个分支的下载出了错，然后后面又重试了。

```bash
## 这样是创建一个浅克隆
git clone --depth 1 -- https://ghproxy.com/https://github.com/cisco/ChezScheme cisco/ChezScheme
## 这样是批量创建几个
echo 'cisco/ChezScheme
rustdesk/rustdesk
tsasioglu/Total-Uninstaller
elixir-lang/ex_doc
triska/the-power-of-prolog
hashicorp/vagrant' | xargs -P0 -i -- bash -c "$(declare -f redoer) ; redoer 'git clone -q --depth 1 -- https://ghproxy.com/https://github.com/{} {}' "
```

我这儿写的报错信息是： `是否成功` 、 `被填入{}的内容` 、 `重试次数` 这三个。

上面示例是拉取远程 Git 库。同时，拉好几个。

但一般而言，其实这个东西是用在这种事上的：你有一堆 `.jpg` 的地址，那个 `.jpg` 还又是非常单纯的 `1.jpg` `2.jpg` .... `1024.jpg` 这样子，你想让电脑尽其所能地批量下载、并对失败的简单粗暴直接重新执行就好，而你又不想写太绕的代码，那么这个定义就有用武之地了。

上述需要，可以像下面这样写。这里假设你的完整网址是这样的：

```
https://shenqibaobei.xx.yoo/pics/1.jpg
https://shenqibaobei.xx.yoo/pics/2.jpg
https://shenqibaobei.xx.yoo/pics/3.jpg
...
https://shenqibaobei.xx.yoo/pics/1024.jpg
```

并且你也已经建好了一个叫 `guigui` 的文件夹准备用来存放这些可爱的图片，那么，在执行过 `redoer` 的定义的前提下，走下面代码就好：

```bash
seq 1 1024 | xargs -P0 -i -- bash -c "$(declare -f redoer) ; redoer 'wget -q https://shenqibaobei.xx.yoo/pics/{}.jpg -O guigui/{}.jpg' "
```

记得一定要有这个文件夹，不然它会好多个进程并发着不停重试，会发生什么我也不知道。

🐙🐙🐙🐙

# EOF

🐊

--------


# 转载遵循

转载本文时，请务必注明作者以及来源： `https://segmentfault.com/a/1190000040173495`


