/*

Exec
----

The purpose of this script is to call short PL/SQL code snippets (usually
one-liner package calls) and to have at the same time the called code formatted
as a list item for a deployment log.

*/

prompt - exec &1
exec &1;