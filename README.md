![](/images/flow.png)
# Dealiasing
This is an indepedent project that uses a sequence of undersampled CT images with subpixel movement to reconstruct a higher resolution image. This process removes the aliasing effects in the undersampled images.
You can refer my report_dealiasing.pdf for more detail.

## Installation and Usage
If you want to verify my result and run my code, 
First you need to clone this git repository.<br />
Then you have to download data [here](https://www.dropbox.com/sh/nwgwy5t80vo1eog/AADYHt4wyS6TQXrlp2HJaPN9a?dl=0). 
Put the data into the same working directory with the code. <br />
In Matlab Console, Type in `realdata_recon_main`.<br />
Remember to include both code and data in the working directory. 

## Reference
Hardie, R. C., K. J. Barnard, and E. E. Armstrong. “Joint MAP Registration and High-Resolution Image Estimation Using a Sequence of Undersampled Images.” IEEE Transactions on Image Processing 6.12 (1997): 1621–1633. Web. 13 May 2016.

## Acknowledgement
* The CT image of stripes used in this study is in the courtesy of the Johns Hopkins Advanced Imaging Algorithm and Instrumentation Laboratory (AIAI), Baltimore, Maryland.
* _im.m_ and _readImg.m_ are the utility function contributed by the member of the Johns Hopkins I-star Lab, Baltimore, Maryland. 
* Efficient_subpixel_registration package : Copyright (c) 2016, Manuel Guizar Sicairos, James R. Fienup, University of Rochester All rights reserved.
