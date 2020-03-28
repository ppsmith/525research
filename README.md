# How to Use the Optimizer
The optimzer file, and randomfixes some are the .m files you need. You will also need to download all of the data files, or download the ones you are interested in, and then change some lines in the code (read below). 

# What is Hill Climbing?
hillClimibing is a search/AI algorithm that starts with a random solution, and the tries to improve upon that solution by randomy trying
new combinations and only changing the current solution if the new solution is better than the current solution. In this use-case, we are trying to get the KL divergence as close to zero as we can, by changing the weighting of the portfolio. 

Imagine a graph that plots weighting combinations against divergences. The goal of this code is to find the global minimum of this graph.

Good Link to learn the basics: https://www.geeksforgeeks.org/introduction-hill-climbing-artificial-intelligence/



# What the Code Does

This code starts with random weights and then calcualtes the divergence. If this divergence is the lowest found so far, it changes 
random weights by small, random amounts, and then calcualtes the new divergece. It does this until divergence of a new ing scheme is not lower than previosuly calculated (this is the formal hill climbing part).

A drawback of pure hillClimbing is local minimums. To avoid this issue, once a minumum is found using the method above, the divergence 
and weights are stored. The code then jumps to another random weight setting and attempts to hillClimb on this new weight scheme. The
jumps are like jumping to an entirely new part of the imaged  divergence/weighing graph. 

The code is written functionally. The hillClimb function does the optimization, and returns the minimum divergence and the weights. 
The getKL method calculates the divergence between two ditributions, dist1 and dist2.
The combineDist() function applies the weight scheme to distributions. It creates the distribution for a given protfolio.
updateWeights() jumps to random, different weights. This function is called after hillClimb fails to find a more optimal solution.
climbWieghts() adjusts the current weight setting by small, random amounts. This function is called during hill climbing. 

The run-time of the code is dependent on the number of jumps to different weight settings, and by the number of assets in the portfolio.
The more jumps you do, the better results you will get. In testing, the code beats the Protfolio Optimization Toolbox after about 150,000 jumps. The more jumps you have, the more time the code will take to run. 150,000 jumps takes 2 minutes, 30 second to complete with 8 assets, and about a minute less with 4 assets.

# How to Customize for Different Portfolios/Jump Values

You should only edit two lines of code to use the code for your purposes: the allData intilization, and the hillClimb while loop. allData is the data you will feed into the code. The first element of all data should always be the dow, or whatever your target ditribution is. The other data in the allData will compromise the portofolio you are trying to fit. So, if you are trying to fit Microsoft and 3M to the dow, the line would be allData = {dow msft mmm}. 

You can also control the number of jumps the code makes. Reducting the number of jumps will make the code run faster. The first line inside the hillCLimb method is a while loop. Changing the value of jump that is checked for change how many jumps the code makes. To make the code only do three jumps, the line would be: while(jumps <= 3). 

When you run the code, it will show you the starting divergence, and then will produce the lowest divergence found, and the weighting scheme. If you want to see which jump you are on, just remove the ';' from the jump increment line in the hillClimb() function. 

Any additions (tracking error calculation, return calculations) will need to be written before the start of the function section.
