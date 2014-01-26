# -*- coding: utf-8 -*-
#!/usr/bin/env python

import glob

# get list of plist files in octopress directory

template_string = '''

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="">
<meta name="author" content="">

<title>WholeSlide Adhoc Distribution</title>

<!-- Bootstrap core CSS -->
<link href="dist/css/bootstrap.css" rel="stylesheet">
<link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap-glyphicons.css" rel="stylesheet">


<link href="font-awesome/css/font-awesome.min.css" rel="stylesheet">

<style type="text/css">

.small-logo {
width: 44px;
height: 44px;

-webkit-border-radius: 10px;
-moz-border-radius: 10px;
border-radius: 10px;

-webkit-box-shadow: 0px 3px 5px 2px , , 0, 0.4);
box-shadow: 0px 3px 5px 2px , , 0, 0.4);
}

</style>

</head>

<body>

    <div class="container">

      <div class="row">
      
        <div class="col-lg-12">
          <h1 class="page-header">WholeSlide<small> Adhoc Distribution</small></h1>
        </div>

      </div>

      <div class="row">
    

        %s

      </div>

      <hr>


      <footer>
        <div class="row">
          <div class="col-lg-12">
            <p>Copyright &copy; WholeSlide, Inc. 2014</p>
          </div>
        </div>
      </footer>
      
    </div><!-- /.container -->

<!-- JavaScript -->
<script src="dist/js/jquery-1.10.2.js"></script>
<script src="dist/js/bootstrap.js"></script>

<!-- Custom JavaScript for the Menu Toggle -->
<script>
$("#menu-toggle").click(function(e) {
  e.preventDefault();
  $("#wrapper").toggleClass("active");
  });
</script>
</body>
</html>'''




deploy_name = 'biolucida'

import plist


file_list = reversed(glob.glob('/Users/stonerri/Dropbox/WholeSlide/opensourcePlan/octopress/source/%s/*.plist' % deploy_name))

print file_list

web_dict = {}

web_string = ''

for f in file_list:

    basename = f.split('/')[-1].split('-')[1]

    if basename not in web_dict.keys():

        a = {}
        a['url'] = 'itms-services://?action=download-manifest&url=http://wholeslide.com/%s/%s' % (deploy_name, f.split('/')[-1])
        a['target'] = 'Adhoc'
        a['version'] = f.split('/')[-1].split('-')[2].split('.')[0]
        a['build'] = f.split('/')[-1].split('-')[3].split('.')[0]
        a['dllink'] = 'http://wholeslide.com/%s/%s' % (deploy_name, f.split('/')[-1].replace('.plist', '.ipa'))

        b = []
        b.append(a)
        web_dict[basename] = b

    else:

        a = {}
        a['url'] = 'itms-services://?action=download-manifest&url=http://wholeslide.com/%s/%s' % (deploy_name, f.split('/')[-1])
        a['target'] = 'Adhoc'
        a['version'] = f.split('/')[-1].split('-')[2].split('.')[0]
        a['build'] = f.split('/')[-1].split('-')[3].split('.')[0]
        a['dllink'] = 'http://wholeslide.com/%s/%s' % (deploy_name, f.split('/')[-1].replace('.plist', '.ipa'))

        b = web_dict[basename]
        b.append(a)
        web_dict[basename] = b


    print web_dict

    app_base_template =   '''
        <div class="col-lg-5 col-md-5">
          <a href="#"><img class="img-responsive" src="%s"></a>


          <h4>%s</h4>
          '''

    end_template = '''</div>

        <div class="col-lg-7 col-md-7">
          <h2>Biolucida Viewer</h2>

          <p>Put copy text here</p>

         
        </div>

        '''


    version_template = '''
    <div class="">
        <div class="well">
            <center>%s - Version %s - Build #%s<br><br>
            <div class="btn-group">
                <a class="btn btn-success  " href="%s">Download and install</a><a class="btn btn-default" href="%s"><span class="glyphicon glyphicon-circle-arrow-down"></span></a>
            </div>
            </center>
        </div>
    </div>
    '''


for k in web_dict.keys():

    web_string += app_base_template % ('mbflogo.jpg', 'Biolucida Viewer - %s' % k)

    all_versions = web_dict[k]

    for vers in all_versions:

        print vers

        web_string += version_template % (vers['target'], vers['version'], vers['build'], vers['url'], vers['dllink'])

    
    web_string += end_template
    # web_string += '</div>'



output_file = '/Users/stonerri/Dropbox/WholeSlide/opensourcePlan/octopress/source/%s/index.html' % (deploy_name)
fout = open(output_file, 'w')

populate_string = template_string % web_string

fout.write(populate_string)
fout.close()

