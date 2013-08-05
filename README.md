CFDSource
=========

'Confidence' Source Control is a plugin for Caché/Ensemble to enable integration with the GIT source control system. CFDSource provides integration with Source Control not based on a check-in/check-out mentatility, but follows the flow of adding features to products. Specifically CFDSource allows you to:

  - Clone a project from a GIT repository (file or GITHub)
  - Start a new development feature
  - Allow periodic check-ins of the work by the developer(s) in the namespace
  - End the feature and merge back into the main development branch (pushing to the remote repository)

It is also possible to create a new GIT repository from an existing Studio project. Further documentation can be found in the /docs folder under root:

  - Install.pdf = How to install CFDSource
  - Usage.pdf = How to use CFDSource
  - GITHub.pdf = How to directly communicate with GITHub via CFDSource
  - Opportunities.pdf = Some limitations and opportunities in the current implementation
  
Whilst installation is covered in document, you need to import the classes (src/main/cache) into any namespace you want to use CFDSource within (or perform package mappings so it is installed once and available in multiple namespaces). Remember to setup the Source Control setting if you want the 'Confidence' menu in Studio. The /releases folder will contain stable releases, but does not neccessarily match the latest code.

CFDSource is released with a GPLv3 license.

    CFDSource. Copyright, Thomas Spencer, 2013.
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

