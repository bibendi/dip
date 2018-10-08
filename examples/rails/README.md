
This is the exmaple of modern Ruby on Rails application. It consists of RoR 5, Postgres, Redis, Webpack, React. All services are described in the docker-compose.yml.

# How this application has been created from scratch?

The main goal of using Docker is not having all dependencies installed on the host machine. So the first question is how to create an application without having rails? First of all, in an empty directory, we should add `Dockerfile`, `docker-compose.yml` and `dip.yml`. Then run `dip bash` where we can temporarily install `rails` gem by running `gem install rails`. After that, we have to generate the skeleton of our application. Run `rails new -d postgresql --skip-turbolinks --skip-bundle --webpack=react --skip --skip-test --skip-system-test .` Type `exit` and we will return into the host machine. Next, fix files permissions by running `sudo chown -R $USER:$USER .`. The last step we will need to run `dip provision`. That's all! Farther we customize the application how do you like. I strongly recommend learning the source code of this application. Maybe you simply decide to pick up it entirely because most pitfalls are found.

# How to run?

This application customized that we may run in two ways. Either run by docker-compose only or by dip. This way we can smoothly and gradually move members of your team to use dip. For veterans is nothing change. They as before running the application by `docker-compose up web webpack` and open `localhost:3000` in a browser. BTW you can try it now after hand setup (see provision section in dip.yml). For progressive users (yeap, I mean us) everything is simple. I hope you already read [how to set up](https://github.com/bibendi/dip/tree/master/docs) local dns for getting the best experience. And nginx must be running by `dip nginx up`. That's all we have to do once. After reboot, it will start automatically. Next simply run `dip provision` and the application will be set up. After that run `dip up webpack` and `dip up web`. Open http://dip-rails.docker and all should work.

WIP
