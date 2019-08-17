#pragma once

#include "4coder_default_include.cpp"

#include <cmath>
#include <cstdlib>

struct switch_to_result
{
    bool Switched;
    bool Loaded;
    View_Summary view;
    Buffer_Summary buffer;
};

inline void
SanitizeSlashes(String Value)
{
    for(int At = 0;
        At < Value.size;
        ++At)
    {
        if(Value.str[At] == '\\')
        {
            Value.str[At] = '/';
        }
    }
}

inline bool
IsH(String extension)
{
    bool Result = (match(extension, make_lit_string("h")) ||
                   match(extension, make_lit_string("hpp")) ||
                   match(extension, make_lit_string("hin")));
    
    return(Result);
}

inline bool
IsCPP(String extension)
{
    bool Result = (match(extension, make_lit_string("c")) ||
                   match(extension, make_lit_string("cpp")) ||
                   match(extension, make_lit_string("cin")));
    
    return(Result);
}

inline bool
IsINL(String extension)
{
    bool Result = (match(extension, make_lit_string("inl")) != 0);
    return(Result);
}

inline switch_to_result
SwitchToOrLoadFile(struct Application_Links *app, String FileName, bool CreateIfNotFound = false)
{
    switch_to_result Result = {};
    
    SanitizeSlashes(FileName);
    
    unsigned int access = AccessAll;
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer_by_name(app, FileName.str, FileName.size, access);
    
    Result.view = view;
    Result.buffer = buffer;
    
    if(buffer.exists)
    {
        view_set_buffer(app, &view, buffer.buffer_id, 0);
        Result.Switched = true;
    }
    else
    {
        if(file_exists(app, FileName.str, FileName.size) || CreateIfNotFound)
        {
            // NOTE(allen): This opens the file and puts it in &view
            // This returns false if the open fails.
            view_open_file(app, &view, expand_str(FileName), false);
            
            Result.buffer = get_buffer_by_name(app, FileName.str, FileName.size, access);
            
            Result.Loaded = true;
            Result.Switched = true;
        }
    }
    
    return(Result);
}

static bool cx_mode = false;
CUSTOM_COMMAND_SIG(enter_cx_mode)
{
	cx_mode = true;
}

CUSTOM_COMMAND_SIG(nop)
{
}

CUSTOM_COMMAND_SIG(kill_line)
{
	View_Summary view = get_active_view(app, AccessOpen);
	Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
	int32_t start_of_line = buffer_get_line_start(app, &buffer, view.cursor.line);
	int32_t end_of_line = buffer_get_line_end(app, &buffer, view.cursor.line);
	if(start_of_line == end_of_line)
		return delete_line(app);
		
	Range range = { start_of_line, end_of_line };;
	if(post_buffer_range_to_clipboard(app, &global_part, 0, &buffer, range.min, range.max))
		buffer_replace_range(app, &buffer, range.min, range.max, 0, 0);
}

CUSTOM_COMMAND_SIG(kill_word_right)
{
	View_Summary view = get_active_view(app, AccessOpen);
	Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);

	int start = view.cursor.pos;
	int end = buffer_boundary_seek(app, &buffer, view.cursor.pos, DirRight, BoundaryAlphanumeric);
	Range range = { start, end };
	if(post_buffer_range_to_clipboard(app, &global_part, 0, &buffer, range.min, range.max))
		buffer_replace_range(app, &buffer, range.min, range.max, 0, 0);
}

CUSTOM_COMMAND_SIG(kill_word_left)
{
	View_Summary view = get_active_view(app, AccessOpen);
	Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);

	int start = buffer_boundary_seek(app, &buffer, view.cursor.pos, DirLeft, BoundaryAlphanumeric);
	int end = view.cursor.pos;
	Range range = { start, end };
	if(post_buffer_range_to_clipboard(app, &global_part, 0, &buffer, range.min, range.max))
		buffer_replace_range(app, &buffer, range.min, range.max, 0, 0);
}

CUSTOM_COMMAND_SIG(find_corresponding_file)
{
    unsigned int access = AccessProtected;
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    
    String extension = file_extension(make_string(buffer.file_name, buffer.file_name_len));
    if (extension.str)
    {
        char *HExtensions[] =
        {
            "hpp",
            "hin",
            "h",
        };
        
        char *CExtensions[] =
        {
            "c",
            "cin",
            "cpp",
        };
        
        int ExtensionCount = 0;
        char **Extensions = 0;
        if(IsH(extension))
        {
            ExtensionCount = ArrayCount(CExtensions);
            Extensions = CExtensions;
        }
        else if(IsCPP(extension) || IsINL(extension))
        {
            ExtensionCount = ArrayCount(HExtensions);
            Extensions = HExtensions;
        }
        
        int MaxExtensionLength = 3;
        int Space = (int)(buffer.file_name_len + MaxExtensionLength);
        String FileNameStem = make_string(buffer.file_name, (int)(extension.str - buffer.file_name), 0);
        String TestFileName = make_string(app->memory, 0, Space);
        for(int ExtensionIndex = 0;
            ExtensionCount;
            ++ExtensionIndex)
        {
            TestFileName.size = 0;
            append(&TestFileName, FileNameStem);
            append(&TestFileName, Extensions[ExtensionIndex]);
            
            if(SwitchToOrLoadFile(app, TestFileName, ((ExtensionIndex + 1) == ExtensionCount)).Switched)
            {
                break;
            }
        }
    }
}

CUSTOM_COMMAND_SIG(find_corresponding_file_other_window)
{
    unsigned int access = AccessProtected;
    View_Summary old_view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, old_view.buffer_id, access);
    
    exec_command(app, change_active_panel);
    View_Summary new_view = get_active_view(app, AccessAll);
    view_set_buffer(app, &new_view, buffer.buffer_id, 0);
    exec_command(app, find_corresponding_file);
}

#define DEFINE_FULL_BIMODAL_KEY(binding_name,normal_code,cx_code) \
CUSTOM_COMMAND_SIG(binding_name) \
{ \
    if(!cx_mode) \
    { \
        normal_code;            \
    } \
    else \
    { \
        cx_code; \
		cx_mode = false;   \
    } \
}

#define DEFINE_BIMODAL_KEY(binding_name,normal_code,cx_code) DEFINE_FULL_BIMODAL_KEY(binding_name,exec_command(app,normal_code),exec_command(app,cx_code))
#define DEFINE_MODAL_KEY(binding_name,cx_code) DEFINE_BIMODAL_KEY(binding_name,write_character,cx_code)

DEFINE_BIMODAL_KEY(modal_exit, nop, exit_4coder);
DEFINE_BIMODAL_KEY(modal_enter_cx_mode, enter_cx_mode, nop);
DEFINE_BIMODAL_KEY(search_or_save, search, save);
DEFINE_BIMODAL_KEY(forward_or_open, move_right, interactive_open_or_new);
DEFINE_BIMODAL_KEY(write_or_change_panel, write_character, change_active_panel);

extern "C" GET_BINDING_DATA(get_bindings)
{
	Bind_Helper context_actual = begin_bind_helper(data, size);
    Bind_Helper *context = &context_actual;
	
	set_all_default_hooks(context);
	default_keys(context);

    begin_map(context, mapid_global);
    {
		bind(context, 'x', MDFR_ALT, command_lister);
		bind(context, 'g', MDFR_CTRL, lister__quit);

	}
	end_map(context);
	
	begin_map(context, mapid_file);
	{
		bind_vanilla_keys(context, write_character);
		
		bind(context, ' ', MDFR_CTRL, set_mark);
		
		bind(context, 'p', MDFR_CTRL, move_up);
		bind(context, 'n', MDFR_CTRL, move_down);
		bind(context, 'b', MDFR_CTRL, move_left);
		bind(context, 'a', MDFR_CTRL, seek_beginning_of_line);
		bind(context, 'e', MDFR_CTRL, seek_end_of_line);

		bind(context, 'b', MDFR_ALT, seek_alphanumeric_left);
		bind(context, 'f', MDFR_ALT, seek_alphanumeric_right);
				
		bind(context, 'v', MDFR_CTRL, page_down);
		bind(context, 'v', MDFR_ALT, page_up);
		
		bind(context, 'd', MDFR_CTRL, delete_char);
		bind(context, 'd', MDFR_ALT, kill_word_right);
		bind(context, key_back, MDFR_CTRL, kill_word_left);
		bind(context, 'k', MDFR_CTRL, kill_line);

		bind(context, 'w', MDFR_CTRL, cut);
		bind(context, 'w', MDFR_ALT, copy);
		bind(context, 'y', MDFR_CTRL, paste);
		
		bind(context, 'x', MDFR_CTRL, modal_enter_cx_mode);
		bind(context, 'c', MDFR_CTRL, modal_exit);
		bind(context, 's', MDFR_CTRL, search_or_save);
		bind(context, 'f', MDFR_CTRL, forward_or_open);
		bind(context, 'f', MDFR_CTRL | MDFR_ALT, open_in_other);
		bind(context, 'o', MDFR_NONE, write_or_change_panel);
		bind(context, 'o', MDFR_CTRL, find_corresponding_file_other_window);
		bind(context, 'o', MDFR_ALT, find_corresponding_file);
	}
	end_map(context);
	return end_bind_helper(context);
}
