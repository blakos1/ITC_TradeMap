# ITC_TradeMap

Get ITC TradeMap data using a web crawler in R.

This code is semi-automatic due to ITC Trademap website being protected by Captcha, if it wasn't for that, the code could be fully automated and run with headless Chrome.

## Dependencies

Code works while using:

* Windows 10
* Chrome 97.0.4692.71
* R version 4.1.0 (2021-05-18)
* Java with PATH and JAVA_HOME variables properly set up
* Chromedriver in PATH

Anything else **might not work**

## Packages needed

``` r
install.packages(RSelenium)
install.packages(wdman)
```

## Authors

[@blakos1](https://github.com/blakos1)

## License

This project is licensed under the MIT License - see the LICENSE file for details
