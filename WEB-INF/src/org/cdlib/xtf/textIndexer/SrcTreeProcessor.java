package org.cdlib.xtf.textIndexer;

/**
 * Copyright (c) 2004, Regents of the University of California
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *   this list of conditions and the following disclaimer in the documentation 
 *   and/or other materials provided with the distribution.
 * - Neither the name of the University of California nor the names of its
 *   contributors may be used to endorse or promote products derived from this 
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.sax.SAXSource;

import net.sf.saxon.om.NamePool;

import org.cdlib.xtf.lazyTree.RecordingNamePool;
import org.cdlib.xtf.servletBase.StylesheetCache;
import org.cdlib.xtf.util.Path;
import org.cdlib.xtf.util.Trace;
import org.cdlib.xtf.util.XMLWriter;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/**
 * This class is the main processing shell for files in the source text 
 * tree. It optimizes Lucene database access by opening the index once at
 * the beginning, processing all the source files in the source tree 
 * (including skipping non-source XML files in the tree), and closing the 
 * database at the end. <br><br>
 * 
 * Internally, this class uses the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
 * class to actually split the source files up into chunks and add them to the
 * Lucene index.
 * 
 */

public class SrcTreeProcessor

{
  
  private IndexerConfig    cfgInfo;
  private XMLTextProcessor textProcessor;
  private StylesheetCache  stylesheetCache = 
                                  new StylesheetCache( 100, 0, true );
  private Transformer      docSelector;
  private int              nScanned = 0;
  
  ////////////////////////////////////////////////////////////////////////////

  /** Default constructor. <br><br>
   * 
   *  Instantiates the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *  used internally to process individual XML source files. <br><br>
   * 
   *  @throws Exception  if the docSelector stylesheet cannot be loaded.
   */
  public SrcTreeProcessor()
  
  {
    
    // Instantiate a text processor object to use on each XML file
    // encountered in the file tree.
    //
    textProcessor = new XMLTextProcessor();
    
  } // SrcTreeProcessor()
  
  
  ////////////////////////////////////////////////////////////////////////////

  /** Indexing open function. <br><br>
   * 
   *  Calls the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#open(IndexerConfig) open()}
   *  method to actually create/open the Lucene index.
   * 
   *  @param cfgInfo   The {@link org.cdlib.xtf.textIndexer#IndexerConfig IndexerConfig}
   *                   that indentifies the Lucene index, source text tree, and
   *                   other parameters required to perform indexing. <br><br>
   * 
   *  @throws IOException  Any I/O exceptions generated by the  
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#open(IndexerConfig) open()}
   *                       method. <br><br>
   */
  public void open( IndexerConfig cfgInfo ) throws Exception
  {
      
    // Hang on to a reference to the config info.
    this.cfgInfo = cfgInfo;
    
    // Open the Lucene index specified by the config info.
    textProcessor.open( cfgInfo );

    // We need to make sure to use a special name pool that records all
    // possible name codes. We can use it later to iterate through and
    // find all the registered keys (it's the only way.)
    //
    if( !(NamePool.getDefaultNamePool() instanceof RecordingNamePool) )
        NamePool.setDefaultNamePool( new RecordingNamePool() );

    // Make a transformer for the docSelector stylesheet.
    File docSelFile = Path.resolveRelOrAbs(new File(cfgInfo.xtfHomePath),
                                  cfgInfo.indexInfo.docSelectorPath);
    Templates templates = stylesheetCache.find( docSelFile.getCanonicalPath() );
    docSelector = templates.newTransformer();
  
    // Give some feedback.
    Trace.info( "Scanning Data Directories..." );
      
  } // open()

  
  ////////////////////////////////////////////////////////////////////////////

  /** Indexing close function. <br><br>
   * 
   *  Calls the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#processQueuedTexts() processQueuedTexts()}
   *  method to flush all the pending Lucene writes to disk. Then it calls the 
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#close() close()} 
   *  method to actually close the Lucene index. <br><br>
   * 
   *  @throws IOException  Any I/O exceptions generated by the 
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#close() close()}
   *                       method. <br><br>
   *
   */
  
  public void close() throws IOException
  
  {
      // Done scanning now.
      Trace.more( " Done." );

      // Flush the remaining open documents.    
      textProcessor.processQueuedTexts();
      
      // Let go of the config info now that we're done with it.
      cfgInfo = null;

      // Close the index database.
      textProcessor.close();
      
  } // close()

  
  ////////////////////////////////////////////////////////////////////////////

  /** Process a directory containing source XML files. <br><br>
   * 
   * This method iterates through a source directory's contents indexing any
   * valid files it finds, any processing any sub-directories. <br><br>
   * 
   * @param currFile   The current file to be processed. This may be a source
   *                   XML file, a file to be skipped, or a subdirectory. <br><br>
   * 
   *  @throws   Exception  Any exceptions generated internally
   *                       by the <code>File</code> class or the  
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *                       class. <br><br>
   * 
   */
  public void processDir( File currFile ) throws Exception
  
  { 
    
    // We're looking at a directory. Get the list of files it contains.
    String[] fileStrs = currFile.getCanonicalFile().list();
    ArrayList list = new ArrayList( fileStrs.length );
    for( int i = 0; i < fileStrs.length; i++ )
        list.add( fileStrs[i] );
    Collections.sort( list );

    // Process all of the non-directory files first. Form a document 
    // representing the directory and all its files.
    //
    StringBuffer docBuf = new StringBuffer( 1024 );
    String dirPath = Path.normalizePath( currFile.toString() );
    docBuf.append( "<directory dirPath=\"" + dirPath + "\">\n" );
    int nFiles = 0;
    for( Iterator i = list.iterator(); i.hasNext(); ) {
        File subFile = new File( currFile, (String) i.next() );
        if( !subFile.getCanonicalFile().isDirectory() ) {
            docBuf.append( "  <file fileName=\"" + 
                           subFile.getName() + "\"/>\n" );
            ++nFiles;
        }
    }
    docBuf.append( "</directory>\n" );
    
    // Now process the document using the docSelector stylesheet.
    boolean anyProcessed = false;
    if( nFiles > 0 ) {
        String inStr = docBuf.toString();
        InputSource docSelectorInput = new InputSource( 
                                                 new StringReader(inStr) );

        if( Trace.getOutputLevel() >= Trace.debug ) {
            Trace.debug( "*** docSelector input ***\n" + inStr );
            Trace.debug( "" );
        }
        
        DOMResult result = new DOMResult();
        docSelector.transform( new SAXSource(docSelectorInput), result );
        
        if( Trace.getOutputLevel() >= Trace.debug ) {
            Trace.debug( "*** docSelector output ***\n" + 
                         XMLWriter.toString(result.getNode()) );
            Trace.debug( "" );
        }
        
        // Iterate the result, and queue any files to index.
        Node node;
        for( node = result.getNode().getFirstChild();
             node != null;
             node = node.getNextSibling() )
        {
            if( node.getNodeType() != Node.ELEMENT_NODE )
                continue;
    
            Element el      = (Element) node;
            String  tagName = el.getTagName();
            String  strVal  = el.toString();
            
            if( tagName.equalsIgnoreCase("indexFiles") ) {
                node = node.getFirstChild();
                continue;
            }
    
            if( tagName.equalsIgnoreCase("indexFile") ) {
                if( processFile(dirPath, el) )
                    anyProcessed = true;
            }
            else {
                Trace.error( "Error: docSelector returned unknown element '" + 
                             tagName + "'" );
                return;
            }
            
        } // for node
        
    } // if nFiles > 0
    
    // If we found any files to process, the convention is that subdirectories
    // contain file related to the ones we processed, and that they shouldn't
    // be processed individually.
    //
    if( anyProcessed )
        return;
    
    // Didn't find any files to process. Try sub-directories.
    for( Iterator i = list.iterator(); i.hasNext(); ) {
        File subFile = new File( currFile, (String) i.next() );
        if( subFile.getCanonicalFile().isDirectory() )
            processDir( subFile );
    }

  } // processDir()
  
  
  ////////////////////////////////////////////////////////////////////////////

  /** Process file. <br><br>
   * 
   * This method processes a source file, including source text XML files, 
   * PDF files, etc. <br><br>
   * 
   * @param parentEl       DOM element representing the current file to be 
   *                       processed. This may be a source XML file, PDF file,
   *                       etc. <br><br>
   * 
   * @return               true if the document was processed, false if it was
   *                       skipped due to skipping rules.<br><br>
   * 
   * @throws   Exception   Any exceptions generated internally by the <code>File</code>
   *                       class or the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor} 
   *                       class. <br><br>
   * 
   */
  public boolean processFile( String dir, Element parentEl ) throws Exception 
  
  {
    File xtfHome = new File(cfgInfo.xtfHomePath);

    // Gather all the info from the element's attributes.
    SrcTextInfo info = new SrcTextInfo();
    
    // First, get the file name and check it.
    String fileName = parentEl.getAttribute( "fileName" );
    if( fileName != null && fileName.length() > 0 ) {
        File srcFile = new File(dir+fileName).getCanonicalFile();
        info.source  = new InputSource( Path.normalizeFileName(srcFile.toString()) );
        if( !srcFile.canRead() ) {
            Trace.error( "Error: cannot read input document '" + srcFile.toString() + "'" );
            return false;
        }
    }
    else {
        Trace.error( "Error: docSelector must return 'fileName' attribute" );
        return false;
    }
    
    // Optional attributes come after. Is there an input filter specified?
    String strVal = parentEl.getAttribute( "inputFilter" );
    if( strVal != null && strVal.length() > 0 ) {
        File inFilterFile = Path.resolveRelOrAbs(xtfHome, strVal).getCanonicalFile();
        info.inputFilter  = stylesheetCache.find( inFilterFile.toString() );
    }
    
    // If there a display stylesheet specified?
    strVal = parentEl.getAttribute( "displayStyle" );
    if( strVal != null && strVal.length() > 0 ) {
        File displayFile  = Path.resolveRelOrAbs(xtfHome, strVal).getCanonicalFile();
        info.displayStyle = stylesheetCache.find( displayFile.toString() );
    }
    
    // Is there a format specified?
    strVal = parentEl.getAttribute( "format" );
    if( strVal == null || strVal.length() == 0 ) {
        String lcFileName = fileName.toLowerCase();
        if( lcFileName.endsWith(".xml") )
            info.format = "XML";
        else if( lcFileName.endsWith(".pdf") )
            info.format = "PDF";
        else if( lcFileName.endsWith(".htm") || lcFileName.endsWith(".html") )
            info.format = "HTML";
        else {
            Trace.warning( "Warning: cannot deduce format from extension on file '" +
                           info.source.getSystemId() );
            return false;
        }
    }
    else {
        info.format = strVal;
        if( info.format.equalsIgnoreCase("XML") )
            info.format = "XML";
        else if( info.format.equalsIgnoreCase("PDF") )
            info.format = "PDF";
        else if( info.format.equalsIgnoreCase("HTML") )
            info.format = "HTML";
        else {
            Trace.error( "Error: docSelector returned unknown format: '" +
                         info.format + "'" );
            return false;
        }
    }
    
    // Print out dots as we process large amounts of files, just so the
    // user knows something is happening.
    //
    if( ((nScanned++) % 200) == 0 )
        Trace.more( "." );

    // Call the XML text file processor to do the work.    
    textProcessor.queueText( info );
    
    // Let the caller know we didn't skip the file.
    return true;
        
  } // processFile()
  
} // class SrcTreeProcessor
