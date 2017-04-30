"use strict";

var assert = require ('assert');
var util = require ('util');
var _ = require ('lodash');

var originalFile = process.argv[2];
var verifyFile = process.argv[3];
var points = parseInt (process.argv[4]);
var verify = process.argv[5];

var originalTree;
var verifyTree;

// console.log (process.argv);

try
{
	originalTree = require ('./'+originalFile);
}
catch (e)
{
	console.error ('Cannot load original tree from '+originalFile);
	process.exit (-1);
}

try
{
	verifyTree = require ('./'+verifyFile);
}
catch (e)
{
	console.error ('Cannot load tree from '+verifyFile);
	process.exit (-1);
}

// symbol
if (verify === 'symbol')
{
	if (verifyTree.symbol_table)
	{
		if (_.isEqualWith (originalTree.symbol_table, verifyTree.symbol_table, function (original, verify, key)
		{
			// console.log (key)
			if (key === 'value')
			{
				return true;
			}
			// else return _.isEqual (original, verify);
		}))
		{
			
		}
		else
		{
			// console.log ('error');
			process.exit (-1);
		}
	}
	else
	{
		console.log ('No symbol table found');
		process.exit (-1);
	}
}

// ast
if (verify === 'ast')
{
	if (verifyTree.ast)
	{
		if (_.isEqualWith (originalTree.ast, verifyTree.ast))
		{
			console.log ('ok');
		}
		else
		{
			// console.log ('error');
			process.exit (-1);
		}
	}
	else
	{
		console.log ('No AST found');
		process.exit (-1);
	}
}

// error
if (verify === 'error')
{
	if (verifyTree.error_list)
	{
		if (_.isArray (verifyTree.error_list))
		{
			if (originalTree.error_list.length === verifyTree.error_list.length)
			{
				// var error = false;
				for (var originalErrorIndex in originalTree.error_list)
				{
					var originalError = originalTree.error_list[originalErrorIndex];
					if (_.find (verifyTree.error_list, function (verifyError)
					{
						return _.isEqualWith (originalError, verifyError, function (original, verify, key)
						{
							if (key === 'expected' || key === 'token' || key === 'text')
							{
								return true;
							}
						});
					}))
					{

					}
					else
					{
						// console.log ('error');
						console.log ('Error '+originalError+' is not in your error list');
						process.exit (-1);
					}	
				}
			}
			else
			{
				console.log ('You have a different number of errors');
				process.exit (-1);
			}
		}
		else
		{
			console.log ('Error part is not an array');
			process.exit (-1);
		}
	}
	else
	{
		console.log ('No error list found');
		process.exit (-1);
	}
}
