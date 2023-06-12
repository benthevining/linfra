# -*- coding: utf-8 -*-

# ======================================================================================
#  __    ____  __  __  ____  ___
# (  )  (_  _)(  \/  )( ___)/ __)
#  )(__  _)(_  )    (  )__) \__ \
# (____)(____)(_/\/\_)(____)(___/
#
#  This file is part of the Limes open source library and is licensed under the terms of the GNU Public License.
#
#  Commercial licenses are available; contact the maintainers at ben.the.vining@gmail.com to inquire for details.
#
# ======================================================================================

from pygments.style import Style
from pygments.token import Name, Comment, String, Number, Operator, Whitespace


class LinfraTemplateStyle(Style):
	"""
 For more token names, see pygments/styles.default.
 """

	background_color = '#f8f8f8'
	default_style = ''

	styles = {
	    Whitespace: '#bbbbbb',
	    Comment: 'italic #408080',
	    Operator: '#555555',
	    String: '#217A21',
	    Number: '#105030',
	    Name.Builtin: '#333333',  # anything lowercase
	    Name.Function: '#007020',  # function
	    Name.Variable: '#1080B0',  # <..>
	    Name.Tag: '#bb60d5',  # ${..}
	    Name.Constant: '#4070a0',  # uppercase only
	    Name.Entity: 'italic #70A020',  # @..@
	    Name.Attribute: '#906060',  # paths, URLs
	    Name.Label: '#A0A000',  # anything left over
	    Name.Exception: 'bold #FF0000',  # for debugging only
	}
