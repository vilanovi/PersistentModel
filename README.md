PersistentModel
===============

Easy creation for persistent model for iOS and OS X.
 
	This repository is being created now. The full description and how it works guide will be added in the next days also with code comments.

*PersistentModel* uses the same concept of **context** and **persistent store** as *CoreData* does mixed with a `NSCoding` protocol to encode and decode model objects. 

Write down your classes by code and add the coding protocol and you will have a full operational persistent object management. It’s fast, simple, and very useful when there is no need to create complex queries among all set of objects. 

Also, *PersistentModel* supports multiple key accessing via KVC, meaning you can define additional keys to access and retrieve your properties. This is very useful to set values from dictionaries whose come from some external server.

## Overview###

*PersistentModel* can be divided in three parts:

- **Base Object**: Superclass of your persistent objects. Handles relations with the context and have support for multiple key accessing via KVC.

- **Object Context**: Live instances manipulation and management. Responsible of interact with the persistent store and save & load instances to the persistence.

- **Persistent Store**: Persistence layer of the model, data base interactions.

Each part can be configured and depending of your needs you must choose the right configuration.

### Base Objects ###

*TODO*

### Object Context ##
*TODO*

### Persistent Store ###
*TODO*

---
## Examples of usage ##

Many differents situations can be solved with the *PersistentModel*. Here we present a couple of them where we could appreciate the easy solution provided using this framework (or pattern).

#### Communicating in JSON with an external server ####
*TODO*

#### Using the ObjectContext appropiately ####
*TODO*


---
## Repository dependences ##

- **FMDB** (SQLite management): <https://github.com/ccgus/fmdb>

---
## Licence ##
*TODO*