![](images/flow.png ?raw=true)
# Dealiasing
This is an indepedent project that uses a sequence of undersampled CT images with subpixel movement to reconstruct a higher resolution image. This process removes the aliasing effects in the undersampled images.
The algorithm applied here are sub-pixle registration and gradient descent optimization.
You can refer a report_dealiasing.pdf for more detail.

# Usage
clone this git repository and use Matlab to run it.

# Data
The sample data need to be downloaded from my dropbox [here](https://www.dropbox.com/sh/nwgwy5t80vo1eog/AADYHt4wyS6TQXrlp2HJaPN9a?dl=0)

The CT image of stripes used in this study is in the courtesy of the Johns Hopkins Advanced Imaging Algorithm and Instrumentation Laboratory (AIAI), Baltimore, Maryland.

# Limits
* This algorithm only work for undersampled data sequence with horizontal subpixel movement.

# Reference
_ Hardie, R. C., K. J. Barnard, and E. E. Armstrong. “Joint MAP Registration and High-Resolution Image Estimation Using a Sequence of Undersampled Images.” IEEE Transactions on Image Processing 6.12 (1997): 1621–1633. Web. 13 May 2016. _