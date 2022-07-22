#pragma once

#include "BeefySysLib/Common.h"
#include "BeefySysLib/util/Hash.h"
#include "Compiler/BfUtil.h"
#include "DebugCommon.h"

// BEGIN: toml

// including "toml.h" in this section. implementing a "failwith()" function, so that
// toml does not require exceptions to work.

#include <sstream>
#include <iostream>

inline std::string toml_failwith_format(std::stringstream& ss)
{
	return ss.str();
}

template <typename T, typename... Args>
std::string toml_failwith_format(std::stringstream& ss, T&& t, Args&&... args)
{
	ss << std::forward<T>(t);
	return toml_failwith_format(ss, std::forward<Args>(args)...);
}

// implement "failwith()" function, so that toml does not require exceptions and we can compile with "-fno-exceptions" globally.
template <typename... Args>
#if defined(_MSC_VER)
__declspec(noreturn)
#else
[[noreturn]]
#endif
void failwith(Args&&... args)
{
	std::stringstream ss;
	std::cerr << toml_failwith_format(ss, std::forward<Args>(args)...) << std::endl;
	std::cerr << "TODO: how to do toml error reporting without exceptions? (not aborting here but program might crash soon)" << std::endl;
	exit(1);
}

#include "extern/toml/toml.h"

// END: toml

NS_BF_BEGIN

class DebugVisualizerEntry
{
public:
	class ExpandItem
	{
	public:
		String mName;
		String mValue;
		String mCondition;
	};

	class DisplayStringEntry
	{
	public:
		String mCondition;
		String mString;
	};

	enum CollectionType
	{
		CollectionType_None,
		CollectionType_Array,
		CollectionType_IndexItems,
		CollectionType_TreeItems,
		CollectionType_LinkedList,
		CollectionType_Delegate,
		CollectionType_Dictionary,
		CollectionType_ExpandedItem,
		CollectionType_CallStackList
	};

public:
	String mName;
	DbgFlavor mFlavor;
	OwnedVector<DisplayStringEntry> mDisplayStrings;
	OwnedVector<DisplayStringEntry> mStringViews;
	String mAction;

	OwnedVector<ExpandItem> mExpandItems;
	CollectionType mCollectionType;

	String mSize;
	Array<String> mLowerDimSizes;
	String mNextPointer;
	String mHeadPointer;
	String mEndPointer;
	String mLeftPointer;
	String mRightPointer;
	String mValueType;
	String mValuePointer;
	String mTargetPointer;
	String mCondition;
	String mBuckets;
	String mEntries;
	String mKey;
	bool mShowedError;
	bool mShowElementAddrs;

	String mDynValueType;
	String mDynValueTypeIdAppend;

public:
	DebugVisualizerEntry()
	{
		mFlavor = DbgFlavor_Unknown;
		mCollectionType = CollectionType_None;
		mShowedError = false;
		mShowElementAddrs = false;
	}
};

class DebugVisualizers
{
public:
	Val128 mHash;
	String mErrorString;
	String mCurFileName;
	const char* mSrcStr;
	OwnedVector<DebugVisualizerEntry> mDebugVisualizers;

	void Fail(const StringImpl& error);
	void Fail(const StringImpl& error, const toml::Value& value);

	String ExpectString(const toml::Value& value);
	bool ExpectBool(const toml::Value& value);
	const toml::Table& ExpectTable(const toml::Value& value);
	const toml::Array& ExpectArray(const toml::Value& value);

public:
	DebugVisualizers();

	bool ReadFileTOML(const StringImpl& fileName);
	bool Load(const StringImpl& fileNamesStr);
	DebugVisualizerEntry* FindEntryForType(const StringImpl& typeName, DbgFlavor wantFlavor, Array<String>* wildcardCaptures);

	String DoStringReplace(const StringImpl& origStr, const Array<String>& wildcardCaptures);
};

NS_BF_END
