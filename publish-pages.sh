git checkout gh-pages
git merge master
pandoc --from markdown --to html --standalone README.md -o README.html
git add .
git commit -m "Update html pages"
git push --all
git checkout master

