##Cache 实验说明##
**实验目的：实现一个二路组相连Cache，同时Instruction Cache 与Data Cache相分离，大体结构如下：**

![cache框架](https://github.com/Paraoia/CS-Cache/tree/master/pic/cache框架.png)

**框架解释：**
Cache内部分成两个Cache，即Data Cache与Instruction Cache，两者的访问与交互通过Cache Control进行控制，整体通过最顶层的接口Cache Interface与CPU以及内存DDR进行交互。Instruction Cache除了从内存DDR读入指令，也可以从Data Cache读入指令，因为本身实验结构（不是Cache本身特点）造成的***Data Cache存在指令残留问题*** *（在后面说明了该问题原因）*


###NO1.分离的选择###
Cache可以实现为数据指令分离式也可以实现为合并式，那选择哪种进行实现？实际都可以，但此处框架选择了分离，下面对于两者优劣进行阐述。
 
合并：在实现Cache中可以让Instruction Cache与Data Cache合并为一个Cache，实际上intel框架中layer2 Cache就是合并的Cache，相对于分离的优点是电路更加简单，不需要区分指令或数据，且不需要考虑我们本身实验结构（不是Cache本身特点）造成的***指令残留问题*** *（在后面说明了该问题原因）*

分离：将Instruction Cache与Data Cache分离开，并使用同一的管理部件管理，如图所示。intel框架layer1 Cache就是分离的Cache，相对于合并的优点是：
>一者Instruction Cache访问不被Data Cache的miss情况影响，某些情况Data Cache miss rate很高，如果合并会让Instruction Cache miss rate也很高，降低了Cache性能。

>二者可以减少读口数量，假设实现Cache的SRAM大小共4KB，且Instruction Cache需要2个读口，Data Cache需要2个读口，那么分离则是两个2KB的SRAM，每个SRAM两读口，而合并则是一个4KB的SRAM，每个SRAM四读口。而在体系结构课程中会学习到，2KB 2读口的SRAM访问延迟小于4KB 4读口的SRAM，因此分离延迟小于合并。


###NO.2指令残留问题###
这个Cache是和后一个流水线实验【流水线CPU实验：[https://github.com/NJU-SYS-2016/Pipeline-cpu](https://github.com/NJU-SYS-2016/Pipeline-cpu "流水线CPU实验")】（该实验框架如下图所示）相关联的，因此此Cache在具有Cache本身特征的同时，需要能够配合流水线CPU实验进行使用。在该实验中要启动执行则需要执行代码先从外设读入DDR2,即执行代码先从spi flash中加载至CPU中，CPU将该代码写入Cache，Cache再将代码与数据写回DDR2中（写入时是将数据与指令均写入Data Cache中，当Data Cache空间不够时会自动发生写回），因此在写回时可能在Data Cache中会存在残留的指令。
>
>Data Cache存在残留指令有两种方式进行解决：
>
>a、设置在代码加载完时，Data Cache进行一次清空，即将Data Cache中的代码全部写回到DDR2中，这样在Data Cache中需要进行这个功能的实现，逻辑较为麻烦，且电路多。但以Verilog语言来看，容易解决。实际上下文所说的cs552就是这样解决的。
>
>b、对Instruction Cache提供一个接口，使得Instruction Cache先读Data Cache，如果Data Cache出现miss的情况，再读DDR2相应的地址。实现算不麻烦，因此，我们此次实验中采取了这个方案，也因此有了从Data Cache连接到Instruction Cache的一根线。


![流水线CPU总框架.png](https://github.com/Paraoia/CS-Cache/tree/master/pic/流水线CPU总框架.png)




###实验关联说明###

1、原始的cache实验内容是UWsic的cs552中的实验，其中实现了一个直接映射的cache，网址为：

	http://pages.cs.wisc.edu/~david/courses/cs552/S12/includes/cache-mod.html

上述讲义为学生提供了设计一个直接映射的cache的基本示例，可以参考该设计风格进行设计。
