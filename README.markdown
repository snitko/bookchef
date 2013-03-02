Bookchef
=========
A library to convert bookchef.xml file tree into an actual book (currently HTML and PDF are supported).
bookchef.xml is A VERY SIMPLE xml format that I designed to write books. **Yes, I've actually written and successfully published a book with it.**


Installation
------------

1. Install **wkhtmltopdf** as explained in [this Wiki](https://github.com/pdfkit/pdfkit/wiki/Installing-WKHTMLTOPDF). It's a utility that converts html to pdf that Bookchef is going to need.

2. `gem install bookchef`
    
Now a `bookchef` command is available on your system. Type it to see a short summary on how to use it. You will be able to do everything from the command line, but, of course, you may load necessary classes in your ruby program.


Bookchef XML basics
-------------------

Once I decided to write a book. I didn't want to use any proprietary software -- I wanted to use git, my text-editor and a simple xml format (and I mean, really simple) that you can write by hand, so that later I could maybe build some kind of gui-editor around it. In order to make git useful, I realized that each chapter and each section of the chapter should be in a separate file and a seperate directory. Thus we have `<chapter>` and `<section>` tags, each may or may not have an `src=` attribute. Here's an example:

    <book>
      <chapter>
          <section src="section1.xml"/>
          <section src="section2.xml"/>
          <section>And this one doesn't have a seperate file</section>
      </chapter>
    
      <!-- Automatically loads chapter2/index.xml
      if file name is not specified, e.g. doesn't end on .xml -->
      <chapter src="chapter2"></chapter>
    </book>
    
Because chapters and sections may be in seperate files, it will be much easier to parse git diffs in the future, when and if this gui editor arrives. Also, it makes it easy to to manually navigate through the book with just your text editor. Assuming this file is called `index.xml` (and for now it is a requirement for a file which contains a `<book>` tag) I don't recommend using any kind of internal links (like footnotes and references, see below) in this file, because for now they will be broken. `index.xml` in the root book directory should source all the parts from other files.

Within the book, you may use various elements, listed below:

+ `<title>` may appear once within a chapter or a section, but doesn't have to. While compiling, each chapter automatically gets a number before its title
+ `<code-inline>` allows you to include an inline code
+ `<code>` allows a multi-line block of code. Remember that within it other tags don't work
+ `<p>` is self-exlpanatory
+ `<term>` - wrap a term with it (with standard styles used by compiler the text will appear in italics)
+ `<filename>` is used to indicate either a filename or a url (when it's not supposed to be clicked, for example in the case of http://localhost:3000)

Then we also have two special blocks that may appear at the bottom of each section, which are called `<references>` and `<footnotes>`. Here's how it may look:

    <section>
      <title>Minimum wage: why it doesn't work</title>
      <p><span reference="1">Minimum wage</span> doesn't work because people getting jobs for this wage
      are doing so at the expense of all others who didn't get the same job, when employers were either
      unable to pay for that many employees or simply went out of business. Or, they may indeed comply
      with the law and hire just the same number of employees, in which case they simply <span footnote="1">redistribute these costs on their customers</footnote>,
      who then redistribute these costs on their employers demanding more pay and the circle continues.
      This circle inevitably causes <span footnote="2">either inflation or loss of demand</span>.
      Thus, minimum wage always has its costs, but those costs are not payed by people who are expected to pay.
      </p>
      
      <footnotes>
        <footnote id="1">By raising prices</footnote>
        <footnote id="2">People either start demanding more pay, causing businesses to borrow more from banks or, if it's government employees, causing government to print more money.</footnote>
      </footnotes>
      
      <references>
        <reference id="1" type="article" url="http://en.wikipedia.org/wiki/Minimum_wage">Article about minimum wage on Wikipedia</reference>
      </references>
      
    </section>
  
  As you can see, we referenced both footnotes and references by wrapping some text in `<span>` tags and using either a `footnote=` or `reference=` attributes. In fact, you can add those attributes to other tags, not just `<span>`, but also `<term>` or `<filename>`. It will look like this when compiled:
  
  ![bookchef_compiled_example](https://github.com/snitko/bookchef/raw/master/bookchef_compiled_example.png)
  
  Of course, readers are able to click the links and go straight to the footnote or the reference they chose.
  
  You can also link to other chapters and sections which are placed in a separate file, for example:
  
    we discussed this in the chapter on <a href="../chapter2_supply_and_demand">supply and demand</a>
    
  or you can even say this
  
    we discussed this in the chapter on <a href="../chapter2_supply_and_demand"/>
      
  in which case the content in the `<title>` tags from that section will be used to create a link.
  
  You can have as many subdirectories as you want for each chapter, so if there's a large section within a chapter it makes sense to put it in a separate subdirectory. Just don't forget that each subdirectory must have its `index.xml` file.
  
  That's basically it.
  

How to compile your XML into an actual book
-------------------------------------------

You've written a book using BookChef.xml tags, now you want to make a pdf out of it. That's rather simple to do from the command line:

### Step 0
make sure there's a git repo in your book dir. Otherwise there will be an error (to be fixed).

### Step 1: Merge xml files tree into one big .xml file
    bookchef merge_tree path/to/your/book merged_book.xml
    
### Step 2: Compile this file into an .html file using css styles
    bookchef make_html merged_book.xml compiled_book.html
   
### Step 3: Compile PDF out of this HTML:
    bookchef make_pdf compiled_book.html compiled_book.pdf
    
Same steps can be achieved with Ruby code:

    # Step 1
    merger = BookChef::TreeMerger.new('path/to/your/book', "index.xml")
    merger.run
    merger.save_to "merged_book.xml"
    
    # Step 2
    html_compiler = BookChef::Compiler::HTML.new("merged_book.xml")
    html_compiler.run
    html_compiler.save_to "compiled_book.html"

    # Step 3
    BookChef::Compiler::PDF.new(
      File.read('compiled_book.html'),
      output_file: 'compiled_book.pdf',
      footer_custom_html: "This text will appear in the footer of every page"
    ).compile
    

Customizable styles and compiling to different formats
------------------------------------------------------
There are two directories that you might be interested in to customize the output. First, there's a `lib/bookchef/stylesheets/scss` where you may find a `default.scss` file. This file determines, obviously, what the HTML output will look like in a browser (use `rake compile_css` to create a correposnding css in `lib/bookchef/stylesheets/css`.

To tell compiler which css file to use you'd need to create a new xslt-stylesheet in `lib/bookchef/stylesheets/xslt`. Just copy the default one, find the part where it creates a stylesheet link tag and change the css filename. Then you can tell compiler to use your xslt instead of a default one:

    BookChef::Compiler::HTML.new("merged_book.xml", "#{BookChef::LIB_PATH}/stylesheets/xslt/my_styles.xsl")

Because compiler mostly relies on xslt styles to convert xml into html, you can add you own xslt-styles to create any kind of resulting files, for instance epub or Kindle.
