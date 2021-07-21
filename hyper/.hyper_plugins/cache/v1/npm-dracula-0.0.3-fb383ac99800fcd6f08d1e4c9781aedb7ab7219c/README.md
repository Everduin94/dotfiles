# Dracula
*“I vant to drink your data”*

Dracula (inspired by *DatQL-a* or *dat-quill-a*) is a small JavaScript module for running
[DatQL](https://github.com/Nickersoft/dql) queries directly against your
database, as opposed to simply returning the generated SQL. You can install it
via NPM or Yarn:

```bash
$ npm install dracula --save-dev
$ yarn add dracula --dev
```

Be sure to install v0.0.3 or up, or else you'll get the original library registered
under the "dracula" package name (a now defunct package by [Bozhidar Dryanovski](https://github.com/bdryanovski)).

The API is incredibly simple to use, and is designed only for recent versions of Node. For
example, to hook DatQL into Postgres using Dracula:

```javascript
import { types, Pool } from "pg";
import dracula from "dracula";
import dql from "dql";

const pool = new Pool /* pg config object */();

// Define a query
const query = dql`
query getUser($id) {
    users(id = $id) {
        name
        email
    }
}
`;

// Create a hook to connect DQL to your database
// Queries are always passed to the callback in their parameterized object form
const db = dracula(
  query =>
    new Promise(async (fulfill, reject) => {
      pool.query(params.text, params.values, (err, res) => {
        if (err) reject(err);
        else fulfill(res);
      });
    })
);

const getUser = db(
  query,
  // The 2nd param is only included to demonstrate that you can cherry-pick which query you want to run
  // You can omit it if you only have one query or want only the last defined query to be selected
  "getUser"
);

// You can now pass a config object to getUser() to retrieve a user by its ID
getUser({
  variables: {
    id: 1
  }
}).then(result => {
  console.log(result);
});
```

You can omit some of the above code by doing merging the `db` variable with the
`dracula` include directly:

```javascript
const dracula = require("dracula")(
  query =>
    new Promise(async (fulfill, reject) => {
      pool.query(params.text, params.values, (err, res) => {
        if (err) reject(err);
        else fulfill(res);
      });
    })
);
```

Please note that the API is still relatively new and may change in the future.
