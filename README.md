[![Code Climate](https://codeclimate.com/repos/558252c0e30ba014a800a455/badges/b776ff7b00db44d6bd38/gpa.svg)](https://codeclimate.com/repos/558252c0e30ba014a800a455/feed)

[![Test Coverage](https://codeclimate.com/repos/558252c0e30ba014a800a455/badges/b776ff7b00db44d6bd38/coverage.svg)](https://codeclimate.com/repos/558252c0e30ba014a800a455/coverage)

### Getting started

Checkout this repo, make sure all gems are installed (`bundle`) and run `rake db:migrate` to get the database up.

Next, use the `rake community` task to create a new community (see `tasks/community.rake`). Make sure you use your email address to sign up (you will need to be able to receive emails at this address for MaGIC connect to work).

Then proceed with MaGIC Connect:

### MaGIC Connect

Go to [http://connect.mymagic.my/signup](http://connect.mymagic.my/signup) to signup for a new MaGIC connect account. Use the same email address you used to create your community.

To use MaGIC connect, you have to add the following line to your `/etc/hosts`:

```
127.0.0.1   dashboard-development.mymagic.my
```

and access the site through `http://dashboard-development.mymagic.my:3000`.

When you've created a new community, you can access the community through:
`http://dashboard-development.mymagic.my:3000/$community-slug$`

You will be redirected to MaGIC connect. Sign in with your MaGIC connect account and you should be redirected (and signed in) back to your local community.


### Running the development environment

To start the development environment, run:

```
foreman start
```

Make sure you have all required tools installed (see `Brewfile`).

### Icons used

For Company: "[Building](http://thenounproject.com/term/building/18230/)" by Arthur Schmitt, Public Domain

For Member: "[User](http://thenounproject.com/term/user/43645/)" by Venkatesh Aiyulu, Creative Commons – Attribution (CC BY 3.0)

For Community: "[Network](http://thenounproject.com/term/network/48747/)" by John Chapman, Creative Commons – Attribution (CC BY 3.0)
