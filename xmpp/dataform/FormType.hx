/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp.dataform;

enum FormType {
	
	/**
		The form-submitting entity has cancelled submission of data to the form-processing entity.
	*/
	cancel;
	
	/**
		The form-processing entity is asking the form-submitting entity to complete a form.
	*/
	form;
	
	/** 
		The form-processing entity is returning data (e.g., search results) to the form-submitting entity,
		or the data is a generic data set.
	*/
	result;
	
	/**
		The form-submitting entity is submitting data to the form-processing entity.
		The submission MAY include fields that were not provided in the empty form,
		but the form-processing entity MUST ignore any fields that it does not understand.
	*/
	submit;
}
