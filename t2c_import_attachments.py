#!/usr/bin/python

from __future__ import with_statement
import sys, string, xmlrpclib, re, os, urllib

if len(sys.argv) < 5:
    exit("Usage: " + sys.argv[0] + " spacekey pagetitle contentType filename");

spacekey = sys.argv[1];
pagetitle = sys.argv[2];
contentType = sys.argv[3];
filename = sys.argv[4];

with open(filename, 'rb') as f:
    data = f.read(); # slurp all the data

server = xmlrpclib.ServerProxy('https://xxx.atlassian.net/wiki/rpc/xmlrpc');
token = server.confluence2.login('username', 'password');
page = server.confluence2.getPage(token, spacekey, pagetitle);
if page is None:
    exit("Could not find page " + spacekey + ":" + pagetitle);

attachment = {};
attachment['fileName'] = urllib.unquote(os.path.basename(filename));
attachment['contentType'] = contentType;

server.confluence2.addAttachment(token, page['id'], attachment, xmlrpclib.Binary(data));