// Build the file list in the README.md
var glob = require('glob');
var fs = require('fs')

glob('*.sql', function (err, files) {
    var list = '';
    var readme =
        files.forEach(function (file, index) {
            list += '- [' + file.replace('.sql', '').replace(/_/g, ' ') + '](' + file + ')\n'
        });
    //console.log(list);
    fs.writeFileSync(
        'README.md',
        fs.readFileSync('README.md', 'utf8').replace(
            /<!--start_file_list-->[\s\S]*<!--stop_file_list-->/,
            '<!--start_file_list-->\n' + list + '<!--stop_file_list-->'
        )
    );
});

