---
title: "Week 4"   

---

# **Dangers of Vulnerable Components Introduction** #

This week has much less content in comparison to the others. It focuses more on identifying flaws in your dependencies and updating them.

One tool used by the instructor is called dependency check by OWASP and it scans your project and returns a report with all the dependencies listed and categorizes one by one, saying if they’re vulnerable, if so, it also gives a link to a known CVE.

{{< img src="images/1_week4.PNG" >}}

The command line to scan your projects folder is: ``` dependency-check –scan <path-to-the-folder> ```