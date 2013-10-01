PersistentModel
===============

Easy creation for persistent model for iOS and OS X.
 
	This repository is being created now. The full description and how it works guide will be added in the next days also with code comments.

*PersistentModel* uses the same concept of **context** and **persistent store** as *CoreData* does mixed with a `NSCoding` protocol to encode and decode model objects. 

Write down your classes by code and add the coding protocol and you will have a full operational persistent object management. It’s fast, simple, and very useful when there is no need to create complex queries among all set of objects. 

Also, *PersistentModel* supports multiple key accessing via KVC, meaning you can define additional keys to access and retrieve your properties. This is very useful to set values from dictionaries whose come from some external server.

## Overview###

### Non-Relational Model ###

*PersistentModel* is designed as a non-relational model. What does that mean? That means that there are no relation (by pointers) between your model objects. Instead of that what we do is use an identifier system: each model object has a unique *key* and relations between objects are hold by storing that *key*.

	Relational Model						Non-Relational Model
	
	Object A		Object B				Object A		Object B
	--------		--------				--------		--------
	int field		int anotherField		int key			int key
	B objB									int field		int anotherfield
											int keyB

How do we get the relational objects in that case? we need to use what we call an **ObjectContext**. The ObjectContext is the place where model objects are retained and keept alive and the class responsible of holding the objects and deliver them when needed by implementing methods as *-objectForKey:*.


### Description ###

*PersistentModel* can be divided in three parts:

- **Base Object**: Superclass of your persistent objects. Handles relations with the context and have support for multiple key accessing via KVC.

- **Object Context**: Live instances manipulation and management. Responsible of interact with the persistent store and save & load instances to the persistence.

- **Persistent Store**: Responsible of serializing and deserialize the object context and all the model objects holded by.


### Base Objects ###

Because we are implementing a non-relational model, a **BaseObject**, or model object, contains an identifier or **key**. That key is represented as a *string* and need to be unique, otherwise you won't be able to register the model object into a context holding another object with the same key.

Also, a model object has a weak reference to the context that is registered to. This is very usful in order to navigate through the relations by using the self contained context to retrieve those objects.

In order to create your own model your model classes must be a subclass of **BaseObject** and override the method *+ (NSSet\*)keysForPersistentValues* returning a set of names for all persistent attributes and relational keys. Only those attributes listed in that method will be stored in persitence. The attributes will be accessed, during the serialization action, via KeyValueCoding (KVC). 

The serialization is done via *NSCoding* protocol, that means you can also serialize any custom object implementing the protocol.

### Object Context ##
*TODO*

### Persistent Store ###
*TODO*

---
## Examples of usage ##

Many differents situations can be solved with the *PersistentModel*. Here we present a couple of them where we could appreciate the easy solution provided using this framework (or pattern).

### Communicating in JSON with an external server ###
*TODO*

### Using the ObjectContext appropiately ###
*TODO*


---
## Repository dependences ##

- **FMDB** (SQLite management): <https://github.com/ccgus/fmdb>

---
## Licence ##

Copyright (c) 2013 Joan Martin, vilanovi@gmail.com.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
