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

import java.util.regex.Pattern;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/**
 * This class maintains configuration information about the current index that
 * the TextIndexer program is processing. <br><br>
 *
 * Information stored by this class includes: <br><br>
 * 
 * - The name of the current index being processed. <br>
 * - The path where the Lucene index database is (to be) stored. <br>
 * - The path where the source text for this index can be found. <br>
 * - The path where any XSLT input filters for this index can be found. <br>
 * - A specification for source text files to ignore. <br>
 * - The text chunk size and overlap attributes for the current index. <br>
 * - Specifications for stop word removal. <br><br>
 *   
 */

public class IndexInfo

{
  
  /** Name of the current index being processed (as specified in the index
   *  configuration file.)
   */
  public String indexName;
  
  /** Name of a sub-directory to index, or null to index everything */
  public String subDir;
  
  /** Name of the path to the current index's Lucene database. */
  public String indexPath;
  
  /** Path to the source text for the current index. */
  public String sourcePath;
  
  /** Path to any XSLT pre-filters to be applied to the text for the current 
   *  index.
   */
  public String inputFilterPath;
  
  /** A list of source file names to skip when indexing. */
  public Pattern[] skipFiles;
  
  /** Set of stop words to remove. Stop words are common words such as "the",
   *  "and", etc. which are so ubiquitous as to add little value to queries.
   *  Rather than remove them entirely however, we take an approach suggested
   *  by Doug Cutting (inventor of Lucene).<br><br> 
   * 
   *  Basically, stop words are joined to surrounding normal words. This speeds
   *  queries while still producing good results for requests that contain
   *  a mixture of stop words and normal words (which is by far the most common
   *  case for queries.) <br><br>
   * 
   *  For example, the string "man of war" would be indexed like this:
   *  "man man-of of-war war". This way, searching for "man war" will pull up a
   *  hit, but a search for "man of war" will score higher, as long as the same
   *  stop-word approach is applied to the query.<br><br>
   * 
   *  You might ask what happens in this case: "joke of the year" (two stop
   *  words in a row.) We could index it as "joke joke-of of-the the-year", or
   *  as the longer but more complete "joke joke-of joke-of-the of-the 
   *  of-the-year the-year". The second form doesn't offer much improvement
   *  in searching and would make the index bigger and logic more complex.
   *  So we always combine a stop word with at most one neighboring word.
   *  <br><br>
   * 
   *  The words in this list may be separated by spaces, commas, and/or 
   *  semicolons.
   */
  public String stopWords;
  
  /** Stylesheet from which to gather XSLT key definitions to be computed
   *  and cached on disk. If not an absolute path name, this is interpreted
   *  as a relative path from the XTF_HOME directory. Typically, one would
   *  use the actual display stylesheet for this purpose, guaranteeing that
   *  all of its keys will be pre-cached.<br><br>
   * 
   *  Background: stylesheet processing can be optimized by using XSLT 'keys', 
   *  which are declared with an &lt;xsl:key&gt; tag. The first time a key 
   *  is used in a given source document, it must be calculated and its values 
   *  stored on disk. The text indexer can optionally pre-compute the keys so 
   *  they need not be calculated later during the display process.
   */
  public String displayStyle;
  
  
  /** Text chunk attribute array. Currently this array consists of two entries:
   *  <br><br>
   * 
   *  - The size of the text chunk in words. <br>
   *  - The overlap in words of adjacent text chunks. <br><br>
   * 
   * These array members should be addressed using <code>chunkSize</code>}
   * and <code>chunkOvlp</code> constants defined by this class. 
   * <br><br>
   * 
   * @.notes  For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */     
  public int chunkAtt[];
  
  /** Index into Chunk Attribute Array for the chunk size attribute. <br><br>
   *  
   *  Indexed text stored in the a Lucine index is broken up in to small chunks 
   *  so that search result "summary blurbs" can be easily generated without 
   *  having to load the entire source text. The chunk size attribute reflects 
   *  the chunk size (in words) used by the current index.
   *   
   */
  public final static int chunkSize = 0;

  /** Index into Chunk Attribute Array for the chunk size attribute. <br><br>
   *  
   *  Indexed text stored in the a Lucine index is broken up in to small chunks 
   *  that overlap with adjacent chunks so that "summary blurbs" for proximity
   *  searches can be easily generated without having to load the entire source
   *  text. The chunk overlap attribute reflects the overlap (in words) used by 
   *  the current index.
   *   
   */
  public final static int chunkOvlp = 1;
     
  /** Constant defining the minimum size (in words) of a text chunk. 
   *  Value = {@value}. <br><br>
   * 
   * @.notes  For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public final static int minChunkSize = 2;
 
  /** Constant defining the default size (in words) of a text chunk. 
   *  Value = {@value}. <br><br>
   * 
   * @.notes  For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public final static int defaultChunkSize = 100;

  /** Constant defining the default overlap (in words) of two adjacent text
   *  chunks. Value = {@value}. 
   * 
   * @.notes  For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public final static int defaultChunkOvlp = 50;
  
  /** Constant defining the default list of stop words. These are common words
   *  that are so ubiquitous as to be of little use in queries. Value = {@value}. 
   * 
   * @.notes  For an explanation of stop word handling, 
   *       see {@link #stopWords stopWords}
   */
  public final static String defaultStopWords = 
      "a an and are as at be but by for if in into is it no not of on or s " +
      "such t that the their then there these they this to was will with";

  
  //////////////////////////////////////////////////////////////////////////// 
  
  /**
   * Default constructor. <br><br>
   * 
   * Creates the chunk attribute array, and initializes the 
   * <code>chunkSize</code> entry to
   * {@link org.cdlib.xtf.textIndexer.IndexInfo#defaultChunkSize defaultChunkSize}, 
   * and the <code>chunkOvlp</code> entry to 
   * {@link org.cdlib.xtf.textIndexer.IndexInfo#defaultChunkOvlp defaultChunkOvlp}. 
   */
  public IndexInfo()
  
  {
    
    // Create the chunk attribute array.
    chunkAtt = new int[2];
    
    // Set the default chunk size and overlap.
    chunkAtt[chunkSize] = defaultChunkSize;
    chunkAtt[chunkOvlp] = defaultChunkOvlp;
      
  } //public IndexInfo()
  
  
  ////////////////////////////////////////////////////////////////////////////    
  
  /** Return the size of a text chunk for the current index. <br><br>
   *
   *  @return    The value of the <code>chunkSize</code> attribute. <br><br>  
   *  
   *  @.notes
   *      For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public int getChunkSize() { return chunkAtt[chunkSize]; }
  
  ////////////////////////////////////////////////////////////////////////////    
  
  /** Return the size of a text chunk (in words) for the current index
   *  as a string. <br><br>
   *
   *  @return     The value of the <code>chunkSize</code> attribute converted 
   *              to a String. <br><br>
   * 
   *  @.notes      This method is intended as a convenience call for code that
   *               creats Lucene fields, which are all stored as strings.  
   *               <br><br>  
   * 
   *       For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public String getChunkSizeStr() 
  { 
    return Integer.toString( chunkAtt[chunkSize] ); 
  }
  
  //////////////////////////////////////////////////////////////////////////// 
  
  /** Return the overlap of two adjacent text chunks for the current index. 
   *  <br><br>
   *
   *  @return    The value of the <code>chunkOvlp</code> attribute. <br><br>  
   * 
   *  @.notes  
   *       For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public int getChunkOvlp() { return chunkAtt[chunkOvlp]; }
  
  //////////////////////////////////////////////////////////////////////////// 
  
  /** Return the overlap (in words) for two adjacent text text chunks in the
   *  current index as a string. <br><br>
   *
   *  @return     The value of the <code>chunkOvlp</code> attribute 
   *              converted to a String. <br><br>
   * 
   *  @.notes     This method is intended as a convenience call for code that
   *              creats Lucene fields, which are all stored as strings. 
   *              <br><br>  
   * 
   *       For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public String getChunkOvlpStr() 
  { 
    return Integer.toString( chunkAtt[chunkOvlp] );
  }
  
  //////////////////////////////////////////////////////////////////////////// 
  
  /** Sets the text chunk size attribute for the current index. <br><br>
   *
   *  This method sets the value for the <code>chunkSize</code> 
   *  attribute, coercing its  value to be greater than or equal to the 
   *  {@link org.cdlib.xtf.textIndexer.IndexInfo#minChunkSize minChunkSize} 
   *  value. <br><br>
   *
   *  @return     The resulting coerced chunkSize value. <br><br>  
   *
   *  @.notes     This function also calls the
   *              {@link org.cdlib.xtf.textIndexer.IndexInfo#setChunkOvlp(int) setChunkOvlp()}
   *              method to ensure that the overlap value is valid for the 
   *              chunk size set by this call.
   *              <br><br>  
   * 
   *       For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */
  public int setChunkSize( int newChunkSize )    
  
  {
    
    // If a negative chunk size was passed in, default to entire
    // document indexing.
    //
    if( newChunkSize < minChunkSize ) newChunkSize = minChunkSize;
    
    // Set the new chunk size.
    chunkAtt[chunkSize] = newChunkSize;
    
    // Force the chunk overlap to be valid for the new size.
    chunkAtt[chunkOvlp] = setChunkOvlp( chunkAtt[chunkOvlp] );
    
    // Return the (possibly coerced) chunk size to the caller.
    return chunkAtt[chunkSize];
     
  } // public setChunkSize()
  
  
  //////////////////////////////////////////////////////////////////////////// 
  
  /** Sets the adjacent chunk overlap attribute for the current index. <br><br>
   *
   *  This method sets the value for the 
   *  {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp} attribute, 
   *  coercing its value to be less than or equal to the half the current chunk 
   *  size for the current index. <br><br>
   *
   *  @return    The resulting coerced chunkOvlp value. <br><br>  
   * 
   *       For an explanation of the text chunk size and overlap attributes, 
   *       see {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkSize chunkSize}
   *       and {@link org.cdlib.xtf.textIndexer.IndexInfo#chunkOvlp chunkOvlp}.
   */

  public int setChunkOvlp( int newChunkOverlap ) 
  
  { 
    
    // If the chunk overlap is more than 1/2 the chunk size, 
    // force it to be half the chunk size.
    //
    if( newChunkOverlap > chunkAtt[chunkSize]/2 ) 
        newChunkOverlap = chunkAtt[chunkSize]/2;
    
    // Set the new chunk overlap value.
    chunkAtt[chunkOvlp] = newChunkOverlap;
    
    // And return the (possibly coerced) result to the caller.
    return chunkAtt[chunkOvlp]; 
    
  } // public setChunkOverlap()    

} // class IndexInfo
