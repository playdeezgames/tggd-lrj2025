rm -rf ./pub-html
dotnet publish ./src/TGGDLRJ2025/TGGDLRJ2025.csproj -o ./pub-html -c Release 
rm -f ./pub-html/*.pdb
butler push pub-html/wwwroot thegrumpygamedev/tggd-lrj2025:html
