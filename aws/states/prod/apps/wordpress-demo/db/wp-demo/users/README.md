For now, I'm just using the root user + faking a mysql bootstrap.

In prod, would want a module that bootstrapped the db (created a new db, setup permissions, setup "safe" defaults) and
then modules to manage individual DB users
