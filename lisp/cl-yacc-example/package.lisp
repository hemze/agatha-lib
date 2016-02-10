;;;; package.lisp

grammar-name::=oracle
grammar-context-name::=oracle

cases::={
{
case-name::=test-connection
case-context::=global
case-severity::=5
case-success::={connect established}
case-fail::={connect failed}
case-steps::={start sqlplus; connect as name/password@db}
}
}
