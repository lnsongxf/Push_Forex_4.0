// zmq_sub_dll_0.0.3.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "zmq_sub_dll_0.0.3.h"
#include <string>
#include <zmq.h>
#include <mutex>
#include "zhelpers.h"

/*
int implementation_detail = 42; // We don't care about this;
void *ptr = &implementation_detail; // The void is what we get from the third party lib... could be anything
std::cout << *reinterpret_cast<wchar_t*>(ptr) << std::endl; //debug output ( Yes void ptr is infact 42 )

// You want to store the pointer (void *) into something you can pass to the other program

size_t handle = reinterpret_cast<size_t>(&ptr);

std::cout << "address: " << handle << std::endl;

// If size_t is not available it can be unsigned int on 32bit or unsigned long long on 64bit

// get void* back from handle

void *ptr2 = reinterpret_cast<void*>(handle);

std::cout << *reinterpret_cast<wchar_t*>(ptr) << std::endl; //debug output for me ( Yes void ptr3 is infact 42 )

*/


void *my_context;
void *subscriber;
wchar_t last_message[1024];
std::recursive_mutex subscriber_mutex{};

const wchar_t *conn_and_sub(wchar_t *addr, wchar_t *topic)
{
	char addr_chars[81920];
	size_t addr_chars_value;
	wcstombs_s(&addr_chars_value, addr_chars, 81920, addr, wcslen(addr));

	char topic_chars[81920];
	size_t topic_chars_value;
	wcstombs_s(&topic_chars_value, topic_chars, 81920, topic, wcslen(topic));

	my_context = zmq_ctx_new();
	subscriber = zmq_socket(my_context, ZMQ_SUB);
	zmq_connect(subscriber, addr_chars);
	zmq_setsockopt(subscriber, ZMQ_SUBSCRIBE, topic_chars, topic_chars_value);

	std::string s = std::to_string((long long)subscriber);
	const char * chars = s.c_str();
	size_t response_wide_length;
	mbstowcs_s(&response_wide_length, last_message, chars, strlen(chars));

	return last_message;
}

const wchar_t * receive(const wchar_t *sub_as_ws)
{
	char subscriber_chars[81920];
	size_t subscriber_chars_value;
	wcstombs_s(&subscriber_chars_value, subscriber_chars, 81920, sub_as_ws, wcslen(sub_as_ws));
	long long subscriber = atoll(subscriber_chars);

	std::lock_guard<std::recursive_mutex> guard{ subscriber_mutex };
	//  Read envelope with address
	char *address = s_recv((void *)subscriber);
	//  Read message contents
	if (address == nullptr)
	{
		return L"empty";
	}
	char *contents = s_recv((void *)subscriber);
	size_t response_wide_length;
	mbstowcs_s(&response_wide_length, last_message, contents, strlen(contents));
	free(address);
	free(contents);
	return last_message;
}

void* pub_context;
void* publisher;
wchar_t publisher_wchart[1024];
std::recursive_mutex publisher_mutex{};

const wchar_t* connect(const wchar_t *addr)
{

	char addr_chars[81920];
	size_t addr_chars_value;
	wcstombs_s(&addr_chars_value, addr_chars, 81920, addr, wcslen(addr));

	pub_context = zmq_ctx_new();
	publisher = zmq_socket(pub_context, ZMQ_PUB);
	zmq_connect(publisher, addr_chars);
	std::string s = std::to_string((long long)publisher);
	const char * chars = s.c_str();
	size_t response_wide_length;
	mbstowcs_s(&response_wide_length, publisher_wchart, chars, strlen(chars));

	return publisher_wchart;
}

int send_with_topic(const wchar_t *publisher_wchart, const wchar_t *message, const wchar_t *topic)
{
	char publisher_chars[81920];
	size_t publisher_chars_value;
	wcstombs_s(&publisher_chars_value, publisher_chars, 81920, publisher_wchart, wcslen(publisher_wchart));

	long long publisher = atoll(publisher_chars);
	
	char message_chars[81920];
	size_t message_chars_value;
	wcstombs_s(&message_chars_value, message_chars, 81920, message, wcslen(message));

	char topic_chars[81920];
	size_t topic_chars_value;
	wcstombs_s(&topic_chars_value, topic_chars, 81920, topic, wcslen(topic));
	std::lock_guard<std::recursive_mutex> guard{ publisher_mutex };
	s_sendmore((void *)publisher, topic_chars);
	int value =  s_send((void *)publisher, message_chars);
	return value;
}

int close(const wchar_t* socket)
{
	char socket_chars[81920];
	size_t socket_chars_value;
	wcstombs_s(&socket_chars_value, socket_chars, 81920, socket, wcslen(socket));

	long long publisher = atoll(socket_chars);

	return zmq_close((void *)socket);
}


Czmq_sub_dll_003::Czmq_sub_dll_003()
{
	return;
}