<div align="center">
    <img src="https://github.com/Nickersoft/dql/raw/master/logo.png" width="400" /><br/><br/>

[![Travis](https://img.shields.io/travis/Nickersoft/dql.svg)](https://travis-ci.org/Nickersoft/dql)
[![Maintainability](https://api.codeclimate.com/v1/badges/78ac0fa85c83fea5213a/maintainability)](https://codeclimate.com/github/Nickersoft/dql/maintainability)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/Nickersoft/dql.svg)]()
[![Github file size](https://img.shields.io/github/size/Nickersoft/dql/bin/dql.js.svg)](https://github.com/Nickersoft/dql)

[![Greenkeeper badge](https://img.shields.io/badge/Greenkeeper-enabled-brightgreen.svg)](https://greenkeeper.io/)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/Nickersoft/dql/blob/master/LICENSE.md)
[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg)](https://github.com/prettier/prettier)

</div>

Contents
--------

- [Introduction](#introduction)
    - [What is DatQL?](#what-is-datql)
    - [Installing](#installing)
    - [Motivation](#so-whats-the-point)
    - [Legitimacy](#idk-sounds-like-a-load-of-bull-do-people-even-use-this)
- [The Markup](#the-markup)
    - [Queries & Mutations](#queries--mutations)
    - [Selecting](#select)
    - [Joining](#join)
    - [Inserting & Updating](#insert--update)
    - [Deleting](#delete)
- [API](#api)
- [Caveats](#caveats)
- [Support Table](#support-table)
    
Introduction
------------

### What is DatQL?
DatQL (a working title short for Data Query Language and pronounced *dat-quill*) is a 
[GraphQL](http://graphql.org/)-inspired markup language that compiles to vanilla SQL. While this library is still highly 
experimental, DatQL supports basic SQL operations such as querying, inserting, updating, and even nested join statements.
So instead of writing this:

```sql
SELECT
  user_id
FROM text_messages
  INNER JOIN (SELECT
                users.id AS user_id
              FROM users) ON (users.id = text_messages.user_id)) AS users
WHERE (conversation_id = 5)
```

You can write this:

```
query getUserTextMessages($conversation_id) {
    text_messages(conversation_id = $conversation_id) {
        ...on users(id = text_messages.user_id) {
            id[user_id]
        }
    }
}
```

### Installing
DatQL has the super-slick `dql` package name thanks to [@maxogden](https://github.com/maxogden) and can be installed via
NPM or Yarn:

```bash
$ npm install dql@beta --save-dev
$ yarn add dql@beta --dev
```

Currently, DatQL is only accessible as a CommonJS module that can be used in Node 8+ (maybe earlier, but that's the Babel 
preset it uses, *sooo*..). It is also in beta (so a `beta` tag is required), and must be v0.2.0+, otherwise you'll get 
the old library, which can be found [here](https://github.com/maxogden/dql).

It is also important to note that [@maxogden](https://github.com/maxogden) happens to (coincidentally) be the a prominent 
contributor of the [Dat Project](https://github.com/datproject), a "distributed data community" that is in no way 
related to this project other than just have "dat" in the title. 

### “So... what's the point?”
Right now you're probably thinking *“Big whoop man. Who the hell cares? SQL ain't that difficult.”* Well, let's talk 
database abstraction for a minute. Say you don't want to get bogged down in the specifics of a database language, seeing
you might switch over to a different database in the future. After all, *all query languages are slightly different*. 
What are your current options?

1. Use object-relational mapping (ORM), such as [Laravel](https://laravel.com/) or [Ruby on Rails](http://rubyonrails.org/),
 or even something like [SQLAlchemy](http://docs.sqlalchemy.org/en/latest/orm/) or [Sequelize](http://docs.sequelizejs.com/).
2. Use a query-building library such as [Squel](https://hiddentao.com/squel/), which this library actually uses.

The choices are slim. The biggest issue with ORMs is the fact they usually work best on empty databases, 
where all data is inserted and managed by a locally-defined schema consisting of models and controllers. Query builders
are great, but can hard to swap out later on down the line, and the available API is usually attached to a particular 
language. For example, I used [Squel](https://hiddentao.com/squel/) for all my Node.js database communication, but used
 [Quill](http://getquill.io/) for all my Scala database communication. And in case you're wondering, no, the libraries 
 are nothing like each other, despite doing virtually the same thing.
 
So that's where DatQL comes in. DatQL is an abstraction *over* the abstractions, so to speak. The DatQL markup is parsed
using a publicly-available context-free grammar and can be adapted to virtually any language. While query builders can 
be replaced depending on which language the DatQL library supports, the markup remains unchanged, creating an extensible, 
open way to write SQL. Plus, DatQL at a glance is much easier to understand than SQL, especially for those who are not SQL
experts.

### “Idk... sounds like a load of bull. Do people even use this?”
Yes, as a matter of fact, DQL is slowly replacing all query building operations in the 
[@GoLinguistic](https://github.com/GoLinguistic) codebase (closed source, sorry). DQL was developed out of Linguistic do
to the need for an abstract, unified way for communicating with the platform's Postgres database. As a result, DQL will 
continue to improve and grow to meet the needs of the Linguistic platform.  

The Markup
----------
### Queries & Mutations
DatQL is fairly straightforward to understand. Like GraphQL, .dql files contain a collection of *documents*, which can 
be one of two types: a mutation (insertion/update) or a query. Each document definition contains a name, as well as any 
declared variable parameters it uses. For example:

```
query getBookmarksForUser($user_id) 
```

You can also call neighboring mutations or queries as well (where appropriate), such as:

```
users(id = getUserIDFromPage(102)) {
    id
}
```

### SELECT
Inside the query block, all top-level blocks are tables from which to SELECT from. Currently, only one table block 
per query is supported; however, in the future multiple may be supported. Tables also accept a list of WHICH statements
that filter the results returned. So let's start out by selecting from our `users` table, filtering by entries whose ID 
matches the user ID provided to the query:

```
query getBookmarksForUser($user_id) {
    users(id = $user_id) {
        id
    }
}
```

Like GraphQL, you can specify which fields to return inside each table block. You can alias these fields by specifying
an alias in square brackets ([]) next to the field name.

### JOIN
JOINs take on a form similar to those of fragments in GraphQL. While their fundamental philosophies differ, the syntax 
is the same. JOIN blocks begin with `...on ` and must specify a table name and `ON` clause in parentheticals. Like 
tables, JOIN blocks accept field names, and it is ***strongly advised that you alias all JOIN fields to avoid conflicts***.
So, let's wrap up our statement by joining the `users` table with the `bookmarks` table:

```
query getBookmarksForUser($user_id) {
    users(id = $user_id) {
        id
        
        ...on bookmarks(user_id = users.id) {
            name[bookmark_name]
        }
    }
}
```

### INSERT & UPDATE
INSERT and UPDATE statements are both grouped under mutation documents. Whether the resultant query uses INSERT or UPDATE
is dependent on whether a selector is specified for the table. If one is present, the existing row is updated. If one is
not provided, a new row is inserted. For example, to update a user's name:

```
mutation getBookmarksForUser($user_id, $user_name) {
    users(id = $user_id) {
        name: $user_name
    }
}
```

### DELETE
DELETE statements can only be run on mutations and consist of a single table entry, prefixed with a minus sign (-). 
Deletes *must* contain a selector clause and *cannot* contain any children:
```
mutation deleteUser($name) {
    - users(name = $name)
}
```

API
---
Similar to Apollo's [graphql-tag](https://github.com/apollographql/graphql-tag), DatQL uses an ES2015 template literal 
tag which is supported by most recent versions of Node. Currently, DatQL supports three SQL flavors: MySQL (mysql), PostgresQL (postgres), 
and Microsoft SQL (mssql). The `dql` tag processes documents into a tree, returning a function that accepts variables, as well 
as the name of the query or mutation to execute. By default, DatQL will always execute the last defined document in a 
file. So for our above query:

```javascript
const dql = require('dql').postgres;

const getBookmarksForUser = dql`
    query getBookmarksForUser($user_id) {
        users(id = $user_id) {
            id
            
            ...on bookmarks(user_id = users.id) {
                name[bookmark_name]
            }
        }
    }
`;

/**
 * Outputs { 
 *  text: 'SELECT id, bookmarks.name AS bookmark_name FROM users INNER JOIN (SELECT bookmarks.name, bookmarks.user_id FROM bookmarks) AS bookmarks ON (bookmarks.user_id = users.id) WHERE (id = $1)',
 *  values: [ 1002 ] 
 * } 
 */
const sql = getBookmarksForUser({
    variables: {
        user_id: 1002   
    }
});

// Outputs SELECT id, bookmarks.name AS bookmark_name FROM users INNER JOIN (SELECT bookmarks.name, bookmarks.user_id FROM bookmarks) AS bookmarks ON (bookmarks.user_id = users.id) WHERE (id = 1002)
const sql_str = getBookmarksForUser({
    variables: {
        user_id: 1002   
    }
});
```

By default, DatQL outputs an object containing both the text of the query and any variables associated with it. This 
allows your database engine to sanitize any variables to prevent SQL-injection attacks. To override this behavior, 
simply pass `true` as the last parameter of the function. If your string contains multiple documents, you can
pass in the name of the entry-point document as the first argument of the function like so:

```javascript
getBookmarksForUser('getBookmarksForUser', {
    variables: {
        user_id: 1002   
    }
}, true);
```

To order your query by a specific field, simply pass in the `orderBy` configuration option. By default, all fields are 
in ascending order. To switch to descending, set the `descending` property to `true`:


```javascript
getBookmarksForUser('getBookmarksForUser', {
    variables: {
        user_id: 1002   
    },
    orderBy: 'id',
    descending: true
}, true);
```

Lastly, you can also pass in a `groupBy` option to group aggregated results based on certain fields.

Caveats
-------
As stated, this library is highly experimental. A couple things to note:

1. The library assumes any fields on the left-side of an operator in any `WHICH`/`ON` statement is a field belonging to
the table in question. As a result, they should not be prefixed by the table name. So for example, the following is correct,
assuming the `users` table has `name` field:

    ```
    ...on users(name = 'Tyler')
    ```

    The following ***will not*** work:
    
    ```
    ...on users('Tyler' = users.name)
    ```

2. DatQL is capable of detecting built-in functions, method calls, and variables in `WHICH`/`ON` statements. 
Any text that does not match one of these is susceptible to being recognized as a field name. As a result, try to keep
your selectors simple and keep fields to the left of any operator.

3. While this library is designed to be an abstraction over SQL, certain database-specific functions such as `Now()` have
not yet been abstracted and will need to be changed manually if you switch databases. Ideally, in the future DatQL will 
include its own built-in functions which will automatically be converted between databases.

Support Table
-------------
<table>
    <tr>
        <td rowspan="11">Selecting (63% completed)</td>
        <td>Single Table</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Multiple tables</td>
        <td>✘</td>
    </tr>
    <tr>
        <td>Sub-queries as tables</td>
        <td>✘</td>
    </tr>
    <tr>
       <td>Fields & Aliases</td>
       <td>✔</td>
    </tr>  
    <tr>
       <td>Joins</td>
       <td>✔</td>
    </tr>  
    <tr>
       <td>Filtering</td>
       <td>✔</td>
    </tr>  
    <tr>
        <td>Sorting</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Grouping</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Having</td>
        <td>✘</td>
    </tr>
    <tr>
        <td>Limits & Offsets</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Unions</td>
        <td>✘</td>
    </tr>
    <tr>
        <td rowspan="6">Inserting & Updating (66% completed)</td>
        <td>Fields</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Batch operations</td>
        <td>✘</td>
    </tr>
    <tr>
        <td>Filtering</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Sorting</td>
        <td>✔</td>
    </tr>  
    <tr>
        <td>Limits</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Functions as values</td>
        <td>✘</td>
    </tr>
    <tr>
        <td rowspan="4">Deleting (75% completed)</td>
        <td>Joins</td>
        <td>✘</td>
    </tr>
    <tr>
        <td>Filtering</td>
        <td>✔</td>
    </tr>
    <tr>
        <td>Sorting</td>
        <td>✔</td>
    </tr>  
    <tr>
        <td>Limits</td>
        <td>✔</td>
    </tr>
    
</table>
