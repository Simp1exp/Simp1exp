---
title: "Week 3"   

---

# **Authentication and Authorization** #
## **What’s this?** ##

These two are similar in the sense that they guarantee privacy, but they’re also different. Authentication is who you claim to be. Authorization is what you’re allowed to do. 

In this course, authorization is only defined but not explored further to how these policies are ensured. So, some things like the access control model, vertical and horizontal escalation aren’t mentioned. Since my intention isn’t to go out of the scope of this course, I won’t talk about it.

## **Authentication** ##

### **What’s this?** ###

Authentication is a process that responds to a key question. You’re who you claim to be? There are various types of processes we know and use every day to authenticate ourselves in different systems. We can categorize them into three different types.
1. Something you have. This type of authentication mechanism can be something like a phone. It’s important to be something physical, otherwise ‘Something you have’ and ‘Something you know’ tend to intertwine at some point.

2. Something you know. An example would be a password, a security question, etc…

3. Something you are. Here a good example is your biometrics.

It’s important to notice, in a system that requires authentication, you can have multiple of these in the same category, but for it to be a 2FA(two-factor authentication) or 3FA(three-factor authentication), there must have at least one of them.  One example is your Steam that implements a 2FA, in their case, there is a common login form, followed by a code you get from your mobile device. We’re going to see next one of the most common vulnerabilities that an authentication system has, logic flaws. 

{{< img src="images/1_week3.PNG" >}}

{{< img src="images/2_week3.PNG" >}}

There are 2 security questions passed via a post request. In a real scenario where you don’t have access to the source code. To test this feature, you would have to fuzz all these parameters trying to find something that pops an error or you can be lucky and pops exactly what you’re looking for. 

In this case, we already know this application is insecure and we don’t want to spend time fuzzing it. Our goal here is to understand what is happening, so let’s go to the code and see what it does.

{{< img src="images/3_week3.PNG" >}}

Here is the code responsible for all we need to know. The first thing that we notice is that our answers to those questions are being parsed by a custom function called “parseSecQuestions”, which makes obvious what it does. We already know that custom features are dangerous when not tested intensively. Ok, this method seems interesting. Now, how does it parse the SecQuestions? This function receives the request as a parameter and returns a data structure called hash map(it’s like a dictionary in python), it works with a key: value pair, in this case, String Key: String Value. But, you see, there is a for loop to pass through all parameters and see the ones that contain the string “secQuestion” and if it contains, adds it to the dictionary. Knowing this, our hash map might look something like this {“secQuestion0”: “test”, “secQuestion1”: ”test”}. After we returned the Hash map, there is a method called “didUserLikelyCheat”. I’m not going to dig deep into it, but basically, these checks if the answer to secQuestion0 and secQuestion1 are the ones hardcoded. Next to this method, we have another method called “verifyAccount” inside an if statement that, when true, returns to us a “.feedback(“verify-account.success”)”, plus the parameters of this method are “userId” and the previous parsed HashMap. Ok, this is what we want. Let’s see what the code looks like.

{{< img src="images/13_week3.PNG" >}}

The goal here is to return true, for that, we need to craft a payload that passes through all these conditions without triggering none of them. The first “if” checks if we’re sending the same number of “secQuestion” parameters that the correct request should have, which is 2. The second and the third check if there is a parameter called “secQuestion0” and  “secQuestion1” respectively, and after that, it uses an and gate(&&). Knowing all of this is easy to come up with a proper request, something like this should do the job:

{{< img src="images/4_week3.PNG" >}}
{{< img src="images/15_week3.PNG" >}}

### **How to fix it?** ###

The right way to fix this would be by using a trusted framework, instead of doing this custom logic. In this lesson, the professor fixes this code rewriting it more safely, using concepts like “Fail closed” which ensures that if there is an edge case, it won’t return true. 

``` 
public boolean verifyAccount(Integer userId, HashMap<String,String> submittedQuestions ) { 

    if (submittedQuestions.entrySet().size() != secQuestionStore.get(verifyUserId.size()) { 
        return false; 
    } 
    if (submittedQuestions.containsKey("secQuestion0") && subnittedQuestions.get("secQuestion0").equals(secQuestionStore.get(verifyUserId).get("secQuestion0"))){
        return true; 
    }
    if (submittedQuestions.containsKey("secQuestionl") && subnittedQuestions.get("secQuestionl").equals(secQuestionStore.get(verifyUserId).get("secQuestion1"))){
        return true; 
    } 

return false; 
    
} 
```

## **JWT** ##

### **What’s this?** ###

**JSON Web Token**(JWT) is a secure and trustworthy standard for token authentication. Token authentication is an approach to persist the identity of a user after the initial authentication process. It ensures users don't need to place their credentials every time they want to act. 

The JWT anatomy is:

{{< img src="images/6_week3.PNG" >}}

It’s a long-encoded string with a total of 3 sections separated by dots. The reason for being encoded is simple. It prevents the JWT from breaking applications that don’t allow specific characters. 
See the last part, the “verify signature”? “foo” is a secret key used to encrypt the message using the **HMACSHA512** hash algorithm, this guarantees the integrity of the massage. That way the payload can contain things like “admin”: false, and even if you use a proxy to intercept the **HTTP** request and change the value “admin”: true, it won’t work.

Just to clarify, here’s the basic sequence of getting a token:

{{< img src="images/16_week3.PNG" >}}

Here is the example of JWT vulnerability used in the class:

{{< img src="images/7_week3.PNG" >}}

Our goal is to reset the votes, and for that, we need to be an admin.

{{< img src="images/8_week3.PNG" >}}

Here is the request responsible for resetting all votes. Se the “access_token”? By the structure we can tell already, this is a JWT. So, let’s decode it.

{{< img src="images/9_week3.PNG" >}}

This is what we get when base64 decoding the message.  There are several ways on how this JWT may be vulnerable, but the one chosen for this lab consists in changing the algorithm type to none. So, we just need to change the algorithm to none, the admin to true, and remove the tail from the JWT.

{{< img src="images/10_week3.PNG" >}}

Using that same formula base64(header) + “.” + base64(payload) + “.” + base64(signature), we can create our modified JWT. It’s important to point out that when using a none algorithm, the signature part is erased and the “.” stays. Looks something like this: **“eyJhbGciOiJub25lIn0=.eyJpYXQiOjE2NDc2MTMzODQsImFkbWluIjoidHJ1ZSIsInVzZXIiOiJKZXJyeSJ9.”**

### **How to fix it?** ###

This issue happens because there is no verification on the received algorithm. Then, what we need to do is, verify if the algorithm is the same we expect it to be.

{{< img src="images/11_week3.PNG" >}}

The parse method is the one causing all of this, its purpose should be to parse JWT. The thing is, JWT doesn’t need necessarily to be signed. Seeing that this parse method doesn’t do exactly what we’re looking for, we should use another parser, one that parses signed JWT or what's called JWS. 

{{< img src="images/12_week3.PNG" >}}