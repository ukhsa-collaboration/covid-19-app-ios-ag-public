#! /bin/zsh

if which node > /dev/null
then
    echo "Node is installed!"
else
    echo "You need to install node first: brew install node."
    exit 1
fi

## Cleanup old build
rm -rf build
mkdir -p build

## Create TestReport
xcodebuild test -workspace NHS-COVID-19.xcworkspace -scheme "NHS-COVID-19-Internal" -destination "name=iPhone 11 Pro" -testPlan ReportTests

## Create AppReport
pushd Reporting
swift run Reporter workspace ../NHS-COVID-19.xcworkspace --scheme "NHS-COVID-19-Internal" --method build --output ../AppReport
popd

## Generate documentation
pushd build
git clone git@github.com:nhsx/COVID-19-app-documentation-reporting.git .
git checkout iOS-reporting-but-small
npm install
npm run build:preview ../
popd
