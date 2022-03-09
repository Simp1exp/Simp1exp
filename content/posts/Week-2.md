---
title: "Week 2"  
---

# **Injection Attacks** #
## **What’s this?** ##
-   **Injection attacks** are a class of attacks that consists of supplying untrusted input to a program. The objective is to get an exception case that triggers something, from there understand how this input is being sanitized, and then craft a payload. Between the vulnerabilities that fit in this category, **SQLi** (SQL Injections) and **XXE** (XML External Entity) are what we’re going to learn in this class
## **SQL Injection** ##

### **What’s this?** ###

SQL Injection(SQLi) attack is a code injection technique used to attack data-driven applications. This type of application, in general, uses SQL databases to store information making it possible to insert arbitrary SQL statements. Once bypassing these filters it’s possible to modify and read data from the database. To completely understand SQLi I suggest learning the SQL.

Structured Query Language(SQL) is a language designed for managing data held in a relational database management system. This is what a query looks like:


```SELECT population FROM world WHERE name = "France"```

{{< img src="images/1_week2.PNG" >}}

This is the basics of SQL, which is like a "hello world" in other programming languages. 

Ok, back to SQLi, now we’re going to see what a vulnerable application looks like. This is a Challenge from Webgoat:

{{< img src="images/9_week2.PNG" >}}

Besides “Register” there is also a tab called “Login”, but it doesn’t matter for now.

{{< img src="images/10_week2.PNG" >}}

Intercepting the request with “burp” we see a parameter called “username_reg” with the value “teste”

{{< img src="images/11_week2.PNG" >}}

This first piece of code in the “registerNewUser” method is using the username to check if this user is already registered. 
The parameter in the PUT request is passed to a variable, also called “username_reg”, after that, in red, this variable is concatenated to another string to form a query and this query is placed in another variable called “checkUserQuery”. I logged the value of this string to show what the value of this string is. Remember, this string is going to be executed in the database.

Ok, but is this vulnerable? Because the string is being concatenated, we can modify the structure of this query.

{{< img src="images/12_week2.PNG" >}}

See? This is saying the user “teste’or’1’=’1’—” already exists. This user wasn’t created, so how we’re having this output? 

{{< img src="images/13_week2.PNG" >}}
That input we placed in the form formed this query. With a basic understanding of SQL, you can understand that this is always true. Regardless of the userid, we won’t be able to register a new account. Ok, but how can we exploit this SQLi vulnerability to dump the database, discover user passwords, and so on? Well, this is up to your imagination and understanding of SQL. My goal here is to teach about SQL and how to fix it. Not how to exploit it.

### **How to fix it?** ###

In the course is said about something called parameterized strings or a prepared statement. What you need to know is that this thing ensures the crafted data we send won’t interfere with the structure of the query. Because the query structure has already been defined, the relevant API handles any type of placeholder data safely, so it is always interpreted as data rather than part of the statement’s structure.

{{< img src="images/15_week2.PNG" >}}

Remember I said the login form didn’t matter for us back then? This is why. Since this code is secure, it couldn’t be used as an example. 

## **XML External Entity** ##
### **What’s this?** ###

XXE is also a code injection technique, but different from SQLi, your target is applications that parse XML input. OK, but what is XML? XML is a markup language similar to HTML, it’s generally used to handle data in a standard structure. This language is used in a ton of places such as APIs, UI layouts & styles in android applications, and config files of various frameworks. It looks something like this: 

{{< img src="images/2_week2.PNG" >}}

It’s important to mention that XML has something called entities that are like variables and these variables are defined in a separate part of the document, called Document type definition (DTD). 

{{< img src="images/3_week2.PNG" >}}

This “ENTITY” in the DTD has a property called “SYSTEM" that allows assigning external content to a variable. That is where the name XML external entity comes from.

{{< img src="images/4_week2.PNG" >}}

Knowing only this is enough to perform an XXE, more precisely, an in-band one. So, what’s an in-band XXE? It’s when the XML is parsed and the output is shown on the screen.

Example:
{{< img src="images/5_week2.PNG" >}}
{{< img src="images/6_week2.PNG" >}}

Here is what the actual communication looks like. It’s important to notice the Content-Type as well, depending on how the application is implemented, the header might tell the framework how to parse this body.

{{< img src="images/7_week2.PNG" >}}

What is happening here is that we’re creating an external entity called “test” that refers to a “.”, this dot represents the current directory. After creating this entity, we call it in the ``` <text> ``` tag. This tag carries what’s shown in the comment section. 

{{< img src="images/8_week2.PNG" >}}

### **How to fix it?** ###

The way the instructor solved this lab was by configuring the framework to ignore DTD since the application doesn’t use this XML feature, although sometimes you need internal entities, but not external ones. When this happens, it might be possible to configure the framework you’re using to disable it.

{{< img src="images/14_week2.PNG" >}}