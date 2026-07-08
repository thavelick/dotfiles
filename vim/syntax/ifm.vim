" IFM syntax file
" Language: Interactive Fiction Mapper
" Maintainer: Dave Chapeskie <dchapes@ddm.wox.org>
"
" Note:  This is my first attempt at doing vim syntax highlighting,
"        if there is a better way of doing any of this please e-mail me.
" Note:  This is for version 5.2 of IFM.

" Remove any old syntax stuff hanging around
syntax clear

" Catch keywords in the wrong spot
syntax keyword ifmError contained title map require room item task link join

" IFM statements
" TODO: doesn't complain when there is something betweem the keyword and the
"       string
" TODO: IFM2.0 and above supports changing existing objects by leaving out
"	the string and using the tag, the tag doesn't get hightlighted using
"       ifmId yet.
syntax region ifmTitleStatement	end=";" matchgroup=ifmStatement start="\<title\>" contains=ifmError,ifmComment,ifmString
syntax region ifmMapStatement	end=";" matchgroup=ifmStatement start="\<map\>" contains=ifmError,ifmComment,ifmString
syntax region ifmRequireStatement end=";" matchgroup=ifmStatement start="\<require\>" contains=ifmError,ifmComment,ifmReal
syntax region ifmRoomStatement	end=";" matchgroup=ifmStatement start="\<room\>" contains=ifmError,ifmComment,ifmString,ifmRoomOpt,ifmTagOpt,ifmDirFromOpt,ifmExitOpt,ifmScoreOpt,ifmGoOpt,ifmLengthOpt
syntax region ifmItemStatement	end=";" matchgroup=ifmStatement start="\<item\>" contains=ifmError,ifmComment,ifmString,ifmItemOpt,ifmTagOpt,ifmInOpt,ifmScoreOpt
syntax region ifmTaskStatement	end=";" matchgroup=ifmStatement start="\<task\>" contains=ifmError,ifmComment,ifmString,ifmTaskOpt,ifmTagOpt,ifmInOpt,ifmScoreOpt
syntax region ifmLinkStatement	end=";" matchgroup=ifmStatement start="\<link\>" contains=ifmError,ifmComment,ifmString,ifmLinkOpt,ifmTagOpt,ifmDirOpt,ifmGoOpt,ifmLengthOpt
syntax region ifmJoinStatement	end=";" matchgroup=ifmStatement start="\<join\>" contains=ifmError,ifmComment,ifmString,ifmJoinOpt,ifmTagOpt,ifmDirOpt,ifmGoOpt,ifmLengthOpt
syntax region ifmStyleStatement	end=";" matchgroup=ifmStatement start="\<style\>" contains=ifmId,ifmComment
syntax region ifmEndStyleStatement	end=";" matchgroup=ifmStatement start="\<endstyle\>" contains=ifmId,ifmComment

" Comments
syntax match ifmComment "#.*" contains=ifmTodo
syntax keyword ifmTodo	contained TODO XXX

" Arguments of options which we want highlighted
syntax keyword ifmGoDir contained out in up down
" TODO: ifmString doesn't handle "testStr\\" correctly...
syntax region ifmString	contained start=+"+ skip=+\\"+ end=+"+
syntax match ifmId	contained "[a-zA-Z][a-zA-Z0-9_]*"
syntax match ifmInteger	contained "[0-9]\+"
syntax match ifmReal	contained "[0-9]\+\.[0-9]\+"

" The options which the above arguments are part of
syntax region ifmTagOpt	contained end="\<\S*\>" matchgroup=ifmKeyword start="\<tag\>" contains=ifmId keepend
syntax region ifmScoreOpt contained end="\<[0-9]*\>" matchgroup=ifmKeyword start="\<score\>" contains=ifmInteger keepend
syntax region ifmLengthOpt contained end="\<[0-9]*\>" matchgroup=ifmKeyword start="\<length\>" contains=ifmInteger keepend
syntax region ifmGoOpt	contained end="\<\S*\>" matchgroup=ifmKeyword start="\<go\>" contains=ifmGoDir keepend
syntax region ifmFromOpt contained end="\<\S*\>" matchgroup=ifmKeyword start="\<from\>" contains=ifmId keepend
syntax region ifmInOpt contained end="\<\S*\>" matchgroup=ifmKeyword start="\<in\>" contains=ifmId keepend

syntax keyword ifmExitOpt	contained exit			skipwhite skipempty nextgroup=ifmExitDir
syntax keyword ifmExitDir	contained nw n ne w e sw s se	skipwhite skipempty nextgroup=ifmExitDir
syntax keyword ifmExitDir contained northwest north northeast west east southwest south southeast skipwhite skipempty nextgroup=ifmExitDir

syntax keyword ifmDirFromOpt	contained dir			skipwhite skipempty nextgroup=ifmDirFrom
syntax keyword ifmDirFrom	contained nw n ne w e sw s se	skipwhite skipempty nextgroup=ifmDirFrom,ifmDirFromInt,ifmFromOpt
syntax keyword ifmDirFrom contained northwest north northeast west east southwest south southeast skipwhite skipempty nextgroup=ifmExitDir
syntax match ifmDirFromInt	contained "[0-9]\+"		skipwhite skipempty nextgroup=ifmDirFrom,ifmFromOpt


" Other options:
"    These options take arguments but we don't hightlight them
"    TODO: "in/after last" should have the word 'last' highlighted as a
"    constant, similarily for tasks "in any" should have 'any' highlighted
"    TODO: 'it' and 'them' should be highlighted (e.g. task "xx" need xx drop it)
"    TODO: IFM2.0 added things like "leave all except ID" which should be
"    highlighted.
"    TODO: 'cmd from' and 'cmd to' should be hightlighted instead of just 'cmd'
"    TODO: IFM5.0 added "keep with/until ID [ID...]" for items; 'with'/'until'
"    should be highlighted.
syntax keyword ifmRoomOpt contained link join note need after before leave cmd
syntax keyword ifmRoomOpt contained style
syntax keyword ifmItemOpt contained note need after before style
syntax keyword ifmTaskOpt contained cmd note need after follow do get give lose
syntax keyword ifmTaskOpt contained drop goto style
syntax keyword ifmLinkOpt contained to cmd need after before leave style
syntax keyword ifmJoinOpt contained to cmd need after before leave style
"    These options don't have arguments
syntax keyword ifmRoomOpt contained start oneway finish nodrop nolink nopath
syntax keyword ifmItemOpt contained hidden keep ignore lost finish "given [obsolete]
syntax keyword ifmTaskOpt contained safe ignore finish
syntax keyword ifmLinkOpt contained oneway hidden nopath
syntax keyword ifmJoinOpt contained oneway hidden nopath


" IFM variable assignment
" [Format.]Ident = Integer|Real|String|"undef" ["in style" Id] ;
" TODO: handle "undef" keyword and "in style" clause
syntax region ifmEqInt contained end=";" matchgroup=ifmStatement start="=" contains=ifmInteger
syntax region ifmEqReal contained end=";" matchgroup=ifmStatement start="=" contains=ifmInteger,ifmReal
syntax region ifmEqString contained end=";" matchgroup=ifmStatement start="=" contains=ifmString

syntax keyword ifmIntIdent item_text_fontsize link_dashed link_line_width link_spline link_text_fontsize map_text_fontsize page_rotate room_border_dashed room_border_width room_exit_width room_text_fontsize show_border show_page_border show_items show_tags show_title show_page_title title_fontsize page_title_fontsize map_title_fontsize fit_page show_map_title map_section_spacing show_map_border show_joins keep_unused_items all_tasks_safe solver_messages task_graph_rooms task_graph_orphans skipwhite skipempty nextgroup=ifmEqInt
syntax keyword ifmRealIdent canvas_height canvas_width font_scale link_arrow_size page_height page_margin page_width room_height room_shadow_xoff room_shadow_yoff room_size room_width map_canvas_width map_canvas_height skipwhite skipempty nextgroup=ifmEqReal
syntax keyword ifmStringIdent canvas_background_colour colour_file item_text_colour item_text_font item_text_fontdef link_colour link_inout_string link_text_colour link_text_font link_text_fontdef link_updown_string map_text_colour map_text_font page_background_colour page_border_colour page_size prolog_file room_border_colour room_colour room_exit_colour room_shadow_colour room_text_colour room_text_font room_text_fontdef title_colour page_title_colour map_title_colour title_font page_title_font map_title_font map_border_colour map_background_colour join_format task_graph_attr task_graph_node task_graph_link skipwhite skipempty nextgroup=ifmEqString

syntax keyword ifmFormat ps tk text raw rec skipwhite skipempty nextgroup=ifmIntIdent,ifmRealIdent,ifmStringIdent


" Synchronization.
" Look backwards for a ';' but ignore any that occur in comments or
" strings.  Stop after going back 250 lines without finding a ';'
syntax sync match ifmSyncRoutine grouphere NONE ";"
syntax sync match ifmNoSyncComment "#.*"
syntax sync region ifmNoSyncString start=+"+ skip=+\\"+ end=+"+
syntax sync maxlines=250


if !exists("did_ifm_syntax_inits")
  let did_ifm_syntax_inits = 1
  " The default methods for highlighting.  Can be overridden later
  highlight link ifmStatement	Statement
  highlight link ifmRoomOpt	ifmKeyword
  highlight link ifmItemOpt	ifmKeyword
  highlight link ifmTaskOpt	ifmKeyword
  highlight link ifmLinkOpt	ifmKeyword
  highlight link ifmJoinOpt	ifmKeyword
  highlight link ifmExitOpt	ifmKeyword
  highlight link ifmDirFromOpt	ifmKeyword
  highlight link ifmFromOpt	ifmKeyword
  highlight link ifmKeyword	Type
  highlight link ifmGoDir	Constant
  highlight link ifmDirFromInt	ifmDirFrom
  highlight link ifmDirFrom	Constant
  highlight link ifmExitDir	Constant
  highlight link ifmInteger	Number
  highlight link ifmReal	Number
  highlight link ifmError	Error
  highlight link ifmString	String
  highlight link ifmComment	Comment
  highlight link ifmTodo	Todo
  highlight	 ifmId		term=bold cterm=bold gui=bold
  highlight link ifmFormat	Type
  highlight link ifmIntIdent	ifmIdent
  highlight link ifmRealIdent	ifmIdent
  highlight link ifmStringIdent	ifmIdent
  highlight link ifmIdent	Identifier
endif

let current_syntax = "ifm"

" ifm: ts=8
