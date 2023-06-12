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

from sys import path as sys_path

sys_path.insert(0, r'@CMAKE_CURRENT_LIST_DIR@')

source_suffix = '.rst'
root_doc = 'index'

project = 'Linfra'
author = 'Ben Vining'
copyright = '2022 Ben Vining; released to public ownership under the terms of the GNU Public License'
version = '0'      # feature version
release = '0.0.1'  # full version string
pygments_style = 'colors.LinfraTemplateStyle'

language = 'en'
primary_domain = 'cmake'
highlight_language = 'cmake'

needs_sphinx = '4.1'

nitpicky = True
smartquotes = True
numfig = False

#
# extensions

extensions = [
    'sphinx.ext.autosectionlabel', 'sphinx.ext.githubpages',
    'sphinx.ext.autodoc', 'sphinxarg.ext', 'sphinx.ext.todo',
    'sphinxcontrib.moderncmakedomain'
]

autosectionlabel_prefix_document = True

autodoc_typehints = 'both'

todo_include_todos = True

#
# man pages

man_show_urls = False
man_make_section_directory = False

#
# HTML

# html_baseurl
html_show_sourcelink = False
html_static_path = ['@CMAKE_CURRENT_LIST_DIR@']
html_style = 'linfra.css'
html_theme = 'default'
html_split_index = True
html_copy_source = False
html_scaled_image_link = True

html_theme_options = {
    'footerbgcolor': '#00182d',
    'footertextcolor': '#ffffff',
    'sidebarbgcolor': '#e4ece8',
    'sidebarbtncolor': '#00a94f',
    'sidebartextcolor': '#333333',
    'sidebarlinkcolor': '#00a94f',
    'relbarbgcolor': '#00529b',
    'relbartextcolor': '#ffffff',
    'relbarlinkcolor': '#ffffff',
    'bgcolor': '#ffffff',
    'textcolor': '#444444',
    'headbgcolor': '#f2f2f2',
    'headtextcolor': '#003564',
    'headlinkcolor': '#3d8ff2',
    'linkcolor': '#2b63a8',
    'visitedlinkcolor': '#2b63a8',
    'codebgcolor': '#eeeeee',
    'codetextcolor': '#333333',
}

html_sidebars = {
    '**':
    ['localtoc.html', 'relations.html', 'globaltoc.html', 'searchbox.html']
}

html_last_updated_fmt = '%b %d, %Y'

html_permalinks = True

html_title = f'Linfra {release} Documentation'
html_short_title = f'Linfra {release} Documentation'
# html_favicon

#
# Latex

latex_show_pagerefs = True
latex_show_urls = 'footnote'

#
# Texinfo

texinfo_show_urls = 'footnote'

#
# Linkcheck

linkcheck_retries = 4
