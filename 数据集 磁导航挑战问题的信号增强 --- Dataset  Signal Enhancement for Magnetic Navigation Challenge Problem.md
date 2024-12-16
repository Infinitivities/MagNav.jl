## Dataset

Publicly available flight data can be automatically downloaded within the package itself. This dataset can also be directly downloaded from [here](https://doi.org/10.5281/zenodo.4271803). See the [datasheet](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/datasheet_sgl_2020_train.pdf) for additional high-level information about this dataset. Details of the flights are described in the [readme files](https://github.com/MIT-AI-Accelerator/MagNav.jl/tree/master/readmes).  
公开可用的飞行数据可以在软件包本身中自动下载。此数据集也可以直接从[此处](https://doi.org/10.5281/zenodo.4271803)下载。有关此数据集的其他高级信息，请参阅[数据表](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/datasheet_sgl_2020_train.pdf)。[自述文件中](https://github.com/MIT-AI-Accelerator/MagNav.jl/tree/master/readmes)介绍了外部测试的详细信息。[](https://www.sci-hub.ee/10.5281/zenodo.4271803)[](https://www.sci-hub.ee/10.5281/zenodo.4271803)

## Data Summary 数据摘要

For more detailed information about the available fields please reference the flight data readme [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/sgl_2020_fields_readme.txt). Several fields to pay attention to are as follows:  
有关可用字段的更多详细信息，请[在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/sgl_2020_fields_readme.txt)参考航班数据自述文件。需要注意的几个字段如下：

-   flux\_a\_{x,y,z}, flux\_b\_{x,y,z}, flux\_c\_{x,y,z},  and flux\_d\_{x,y,z} are the available fluxgate (vector) magnetometers. Flux A, C, and D were placed within the cabin, and Flux B was placed at the base of the tail stinger and is considered a truth signal.  
    flux\_a\_{x，y，z}、flux\_b\_{x，y，z}、flux\_c\_{x，y，z} 和 flux\_d\_{x，y，z} 是可用的磁通门（矢量）磁力计。磁通量 A、C 和 D 放置在机舱内，磁通量 B 放置在尾部毒刺的底部，被认为是真值信号。
    
-   mag\_{1,2,3,4,5}\_uc are the available uncompensated scalar magnetometers. Mags 2, 3, 4, and 5 were placed within the cabin and are to be treated as the input signal, as these are the signals of interest for compensation. Mag 1 was placed at the end of the tail stinger and is considered a truth signal.  
    mag\_{1,2,3,4,5}\_uc 是可用的无补偿标量磁力计。磁力 2、3、4 和 5 被放置在机舱内，并被视为输入信号，因为这些是需要补偿的感兴趣信号。Mag 1 位于尾刺的末端，被认为是一个真理信号。
    

Each flight was split into train and evaluation portions, with the primary consideration being a representative sample of each flight location and altitude in the held out evaluation dataset.  
每次飞行都分为训练和评估部分，主要考虑的是保留的评估数据集中每个飞行位置和高度的代表性样本。

### Flight 1002 航班 1002

The goal of this flight was to do 2 compensation loops alongside free flight and a survey repetition. More detailed flight line information is available [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1002_readme.txt). Note that Flux A and Mag 2 had some data integrity issues that led to Flux A being dropped from this flight and Mag 2 not having a signal at 180 degree headings during pitch/roll maneuvers. The affected lines for the problem with Mag 2 are: 1002.02, 1369.00 and 1002.20  
这次飞行的目标是在自由飞行和一次调查重复的同时进行 2 次补偿循环。更详细的航线信息可[在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1002_readme.txt)获得。请注意，Flux A 和 Mag 2 存在一些数据完整性问题，导致 Flux A 从这次飞行中被丢弃，并且 Mag 2 在俯仰/滚动机动期间在 180 度航向没有信号。受 Mag 2 问题影响的线路为：1002.02、1369.00 和 1002.20

### Flight 1003 1003 号航班

The goal of this flight was to collect additional free flight data over several hours. More detailed flight line information is available [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1003_readme.txt). Note that Mag 2 had data issues at a 180 degree heading during pitch/roll maneuvers. The affected lines for the problem with Mag 2 are: 1003.01  
这次飞行的目标是在几个小时内收集额外的免费飞行数据。更详细的航线信息可[在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1003_readme.txt)获得。请注意，Mag 2 在俯仰/滚动机动期间在 180 度航向处存在数据问题。受 Mag 2 问题影响的行为：1003.01

### Flights 1004 & 1005 航班 1004 & 1005

The goal of these flights was to repeat a known mini-survey within Eastern Ontario. Due to weather concerns this collection was split into two data collections. More detailed flight line information is available [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1004_readme.txt) and [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1005_readme.txt).  
这些飞行的目标是在安大略省东部重复一次已知的小型调查。出于天气考虑，此集合被拆分为两个数据集合。更详细的航线信息可[在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1004_readme.txt)和[此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1005_readme.txt)获得。

### Flight 1006 1006 号航班

The goal of this flight was to perform compensation maneuvers at a variety of altitudes and locations. Additional commentary from the pilot is available [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/examples/dataframes/df_event.csv), and more detailed flight information is available [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1006_readme.txt). Note that Mag 2 had data issues at a 180 degree heading during pitch/roll maneuvers. The affected lines for the problem with Mag 2 are: 1006.02, 1006.03, 1006.06, 1006.07, and 1006.08.  
这次飞行的目标是在各种高度和位置执行补偿机动。飞行员的其他评论可[在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/examples/dataframes/df_event.csv)获得，更详细的飞行信息可[在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1006_readme.txt)获得。请注意，Mag 2 在俯仰/滚动机动期间在 180 度航向处存在数据问题。受 Mag 2 问题影响的行为：1006.02、1006.03、1006.06、1006.07 和 1006.08。

### Flight 1007 1007 号航班

The goal of this flight was to collect free flight data within the Perth mini-survey and the Eastern Ontario/Renfrew regions. More detailed flight information is available [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1007_readme.txt).  
这次飞行的目标是在珀斯小型调查和安大略省东部/伦弗鲁地区收集免费飞行数据。更详细的航班信息[可在此处](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/Flt1007_readme.txt)查看。

## Data Sharing Agreement 数据共享协议

Please read the full Data Sharing Agreement located [here](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/DATA_SHARING_AGREEMENT.md).  
请在此处阅读完整的数据共享[协议。](https://github.com/MIT-AI-Accelerator/MagNav.jl/blob/master/readmes/DATA_SHARING_AGREEMENT.md)

By granting You access to Data, the Air Force grants You a limited personal, non-exclusive, non-transferable, non-assignable, and revocable license to copy, modify, publicly display, and use the Data in accordance with this AGREEMENT solely for the purpose of non-profit research, non-profit education, or for government purposes by or on behalf of the U.S. Government. No license is granted for any other purpose, and there are no implied licenses in this Agreement. This Agreement is effective as of the date of approval by Air Force and remains in force for a period of one year from such date, unless terminated earlier or amended in writing. By using Data, You hereby grant an unlimited, irrevocable, world-wide, royalty-free right to The United States Government to use for any purpose and in any manner whatsoever any feedback from You to the Air Force concerning Your use of Data.  
授予您访问数据的权限，即表示 Air Force 授予您有限的个人、非排他性、不可转让、不可转让和可撤销的许可，允许您根据本协议复制、修改、公开展示和使用数据，但仅限于非营利性研究、非营利性教育或美国政府或代表美国政府的政府目的。未出于任何其他目的授予任何许可，并且本协议中没有默示许可。本协议自空军批准之日起生效，自该日期起一年内有效，除非提前终止或以书面形式进行修订。使用数据，即表示您特此授予美国政府无限制的、不可撤销的、全球性的、免版税的权利，以出于任何目的以任何方式使用您向空军提供的有关您使用数据的任何反馈。