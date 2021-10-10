/* ------------------------------------------------------------------
                   Universidad de San Andrés
	        Economía Aplicada - Semestre de Primavera 2021
	                 Heteroskedasticity 
 ------------------------------------------------------------------ */
* We will create values for some variables, using the "actual" values of the linear parameters involved. Then we will try to retrieve those parameters using OLS, being aware of the problem of heterosekedasticity.

* First of all, we're going to run the clear command.

clear

* After that, let's generate a database with 1000 observations. Remember to set the seed to replicate the results.

set seed 101
set obs 1000

* Our first independent variable, x, has mean 0 and standard deviation 1.

gen x = rnormal()

* Now, we are going to generate a variable z to generate the heteroskedasticity. This variable will have a uniform distribution (we multiply it by 5).

gen z = runiform()*5

* Last but not least, our error term. This error will have a normal distribution with mean 0 and sd of 36+40*z.

gen u = ((36+40*z))*rnormal()

* As we can see, as z is not a constant variable, our error term isn't constant. It's different for each observation. This is what we call heteroskedasticity. In this plot, we can see that the error term is not constant.

tw scatter u z , sort mcolor("navy") title(Heteroskedastic Normally Distributed Error) scheme(s1color) 

* Finally, let's generate the data generating process for y. The structure of the dependent variable is five times x plus the error term.

gen y = 5*x+ z + u

* In the presence of heteroskedasticity, it's evident that not all the hypotheses of Gauss-Markov hold; consequently, the OLS estimator is not BLUE. The fact that the estimator is not BLUE doesn't imply that it is not unbiased and inconsistent anymore. The problem arises when we try to perform inference: we won't be correctly estimating the standard errors. Thus, our conclusions of the causal effect might be wrong.

* Let's retrieve the real data generating process of y with an OLS estimation. In this first stage, assume that all the Gauss-Markov hypotheses are true.

reg y x z

* If we had to make conclusions with this regression output, we would say that x is not relevant to explain the outcome.

* As a result of what we learned in the Econometrics class, we are suspicious that there may be heteroskedasticity in the error term. As a first step, we will predict the residuals of our former regression and plot them against the dependent variable.

predict e_hat, resid

tw scatter y e_hat , sort mcolor("navy") scheme(s1color) 

* If we weren't in the presence of heteroskedasticity, we would expect a scatter plot with no evident correlation. In this example, the result is gross. The correlation betweeen both variables is almost perfect: a clear sign of heteroskedasticity.

* To empirically confirm that the error term is not constant, we're going to perform the Breush-Pagan test. First, manually.

* As we already have the residuals predicted, we generate the crucial variable for this test, squared residuals:

gen e_hat_sq = e_hat^2

* Now, we run the regression of the squared residuals against our independent variable

reg e_hat_sq x z

* The test statistic is R^2*n, where n is the sample size. In our case

di 0.1571*1000

* Now let's find the pvalue of this statistic. We know that it has a chi square distribution with k (independent variables) degrees of freedom. In our example, the statistic has 3 degrees of freedom. The p-value is

di chi2tail(3, 157.1)

* Now, the F statistic.

di (0.1571/3)/((1-0.1571)/(1000-3-1))
di Ftail(3, 1000-3-1, 61.878277)

* We reject the null hypothesis of homoscedasticity with both statistics.

* Now, with the command *hettest*:

reg y x z

estat hettest

* White's test

estat imtest 

* We also reject the null hypotesis.

* The result of the test suggests what we already know: our error term is not homoscedastic.

* We have now identified the problem, now we have to come up with a solution. In this example, we know the structure of the heteroskedasticity. As a result, we could use Feasible GLS to estimate the standard errors correctly. In spite of this situation, it is extremely unreal to think that we would know the structure of the error term (if we knew this, we would be God). As a consequence, let's estimate the standard errors with a powerful tool for cross-sectional data: White's robust standard errors.

* In Stata is easy to run a regression with this alternative estimation. We only have to add "robust" as an option when we run the regression.

reg y x z, robust

* In this case, standard error were estimated correctly and the t statistic of our variable of interest, x, raised.

* In this simulation, we learned how to detect heteroskedasticity in a database visually and using a test. Finally, we estimated the standard errors properly. The main lesson of this class is that heteroskedasticity is a significant problem, and if we don't deal with it, we can make wrong conclusions. 
