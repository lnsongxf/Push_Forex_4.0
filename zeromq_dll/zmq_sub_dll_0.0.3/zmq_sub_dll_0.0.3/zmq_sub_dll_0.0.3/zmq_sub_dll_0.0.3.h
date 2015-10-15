// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the ZMQ_SUB_DLL_003_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// ZMQ_SUB_DLL_003_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef ZMQ_SUB_DLL_003_EXPORTS
#define ZMQ_SUB_DLL_003_API __declspec(dllexport)
#else
#define ZMQ_SUB_DLL_003_API __declspec(dllimport)
#endif
// This class is exported from the zmq_sub_dll_0.0.3.dll
class Czmq_sub_dll_003 {
public:
	Czmq_sub_dll_003(void);
	// TODO: add your methods here.
};

const wchar_t* receive(const wchar_t* conn_handle);
const wchar_t* conn_and_sub(const wchar_t *addr, const wchar_t *topic_name);
const wchar_t* connect(const wchar_t *addr);
int send_with_topic(const wchar_t *publisher_wchart, const wchar_t *message, const wchar_t *topic);