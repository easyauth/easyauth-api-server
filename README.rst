##################
Easyauth CA Server
##################

*******************
Project Information
*******************

Introduction
============
As part of our goal of providing a centralized solution for client certificate
authentication, we need a Certificate Authority--and since it has to be public
facing, we need a Certificate Authority Server that can both sign certificates
and handle revocation. This will be implemented with a modular approach, where
the frontend website is *not*, as such, part of the server but the server does
provide the backend where user's certificates are issued, managed, and revoked.

Both the OCSP responder and backend certificate manager will be independent
programs. They will both use the same backend database (certificate store) but
they will have the option of being operated independently should someone so
desire.

This README will function also as a specification document: the needed and
planned functionality will be listed here, below.

Installation
============
This section left out until there's actually something *to* install.

Contributing
============
You'll need a recent version of Ruby and Rails. This was developed on Ruby
2.4.1 and Rails 5.1.1, so any version equal to or greater than that should
hopefully work.

**********************
Project Specifications
**********************
Backend
=======

The backend has the more complicated specification, as it does most of the work.
The frontend (out of scope for this codebase) is simply an interface to the
backend, which handles:

* Certificate management:

  + Certificate issuance
  + Certificate renewal
  + Certificate revocation

* Maintenance of the CRL
* User management:

  + User creation
  + Validation of user email addresses
  + Updating user's profile information

The backend will not have any public-facing interfaces; it will be designed to
work solely with a frontend server. It will listen on either a local port or a
Unix Socket for communication with the frontend and the OCSP responder. The
frontend will be responsible for displaying the CRL.

Despite there being better ways of achieving inter-process communication, we
will use an HTTP API for communication here. As such, it is important that the
backend not be publicly exposed. A secret key will be used, however should that
key be compromised somehow, an attacker would be able to manage certificates
arbitrarily. This API will be properly defined an another document.

OCSP Responder
==============

So that websites can vaildate certificates easily (as they should attempt to
validate each certificate before trying to use it for authentication; indeed,
a website using client certificate authentication but *not* our API has a duty
to validate each certificate lest one be compromised), we need to provide an
OCSP responder. As this is to be used for clients only, we need not implement
`RFC 6961`_, however we do need to implement `RFC 2560`_. That RFC outlines our
requirements nicely.

.. _`RFC 2560`: https://www.ietf.org/rfc/rfc2560.txt
.. _`RFC 6961`: https://tools.ietf.org/rfc/rfc6961.txt
