# Studio Project Manager

## Overview
In the course of my career in music production, I have tried several project management solutions, all with varying degrees of success. Studio Project Manager is my attempt to encapsulate the most important parts of my music recording process in an easy-to use tool I can share with bands and artists. The app is a full-stack Rails application that tips it's hat to Basecamp's "web as documents" approach web development. This means, in part, that I used very little JavaScrip, preferring to send HTML over the wire when possible. The end result is easy to use on desktop and mobile browsers, and I have high hopes that it will be easy to maintain for years to come.

## Lessons Learned

### Devise
Rails provides some built in tools for password hashing, but putting together an entire, custom user authentication system can get complicated. While building Studio Project Manager, I took the opportunity to learn [devise](https://github.com/heartcombo/devise), a powerful tool for authentication in Rack apps. While I did end up investing a decent amount of time into configuring Devise to meet my apps specific needs, I was able to take advantage of all the security work the gem developers have already baked into this tool to include some pretty complex security features at a relatively low cost. The end result is my app users can log in securely, reset their password and email, invite other users, and a great deal more!

BONUS: if you are considering using Devise in your apps, add [a couple easy methods](https://github.com/jhunschejones/Studio-Project-Manager/blob/master/app/models/user.rb#L102-L104) to your model to prevent IP addresses from being stored in your database. Your users will thank you!

### Database Encryption
Devise provides some powerful security tools for protecting my application code, but the app still has to store data in a database running in the cloud. To help improve the security of my user data, I took advantage of the [lockbox](https://github.com/ankane/lockbox)  gem to encrypt user names and emails at the database level. It was easy to set up and I was even able to use it when testing with fixtures (after a little bit of research.) The result of this up-front investment is that if something were to ever go awry in the future, it is now much harder for malicious actors to pull names and emails from my application!

### Sidekiq
In my last project, I used a simple in-memory queue for sending emails to users. As the scope of Studio Project Manager grew however, I realized there were just too many concerns to rely on such a simple approach. Thankfully, [Sidekiq](https://github.com/mperham/sidekiq) was fairly straight forward to set up and work with, both locally and on Heroku. I use it to manage not only emails, but also other async jobs that the app runs like user notifications _(see below.)_ As a result, I do not lose my queue state on app re-starts and I can use background workers to complete important work without distracting my web workers.

### Turbolinks & Rails JavaScript helpers
I am used to running a fair amount of JavaScript on the page to provide user interaction without having to load a new page every time something changes. Thanks to the streamlined process Rails provides, you will see lots of `format.js` responses in my controllers. I found it very easy to use this pattern to send just a little bit of JavaScript back to the browser to modify the DOM on content changes.

### User notifications
One of the app features that was the most fun to work on was the user notification system. At a high level, I wanted a way to keep track of changes that occurred in a project, then email all the project's users once a day to let them know what had happened. This would save me a great deal of time as a music producer, and I've never implemented a system like this before so I was excited to see what it would take!

The result is a few background jobs and some custom emails that do the trick quite handily. When important actions are taken in a project, I make a record of the change. I can then call a rake task once a day to send out a notification email with all the changes from that day. Thanks to Sidekiq, I can count on my background job queue maintaining it's state even with app restarts, so once an email is sent I can mark the notification as delivered and clean up old notifications in another rake task.

To really fill out the user experience of these notifications, I added the ability for users to configure their notification preferences on a per-project basis, allowing them to opt out of emails all together if there's just too much noise. I also included a few recent project changes on the project details page itself. This felt less noisy than a notification feed, but still provides a quick way to see what's been going on if a user has chosen not to receive notification emails.

I recognize this user notification system is still pretty basic, but it definitely free's me up from having to remember to text or email the band after changing a project, and it was a ton of fun to implement!

## Next Steps
Studio Project manager is as much a learning exercise for what is possible with Rails as it is a tool for me to use when working with musicians. I look forward to using the app on my next recording project and I plan to continue to identify more ways to improve the user experience and helpful feature-set. If you have suggestions after reviewing the code, I'm always happy to engage in conversation: find me at joshua@hunschejones.com.
