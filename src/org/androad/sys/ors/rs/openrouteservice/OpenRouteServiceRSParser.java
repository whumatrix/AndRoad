package org.androad.sys.ors.rs.openrouteservice;

import java.util.ArrayList;

import org.osmdroid.util.BoundingBoxE6;
import org.osmdroid.util.GeoPoint;

import org.androad.sys.ors.adt.Error;
import org.androad.sys.ors.adt.rs.Route;
import org.androad.sys.ors.adt.rs.RouteInstruction;
import org.androad.sys.ors.exceptions.ORSException;
import org.androad.util.TimeUtils;
import org.androad.util.constants.Constants;
import org.androad.util.constants.TimeConstants;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import android.util.Log;

public class OpenRouteServiceRSParser extends DefaultHandler implements TimeConstants, Constants {
	// ====================================
	// Constants
	// ====================================

	// ====================================
	// Fields
	// ====================================

	private final ArrayList<Error> mErrors = new ArrayList<Error>();

	private Route mRoute;
	private ArrayList<GeoPoint> mPolyline;

	private GeoPoint tmp;

	private boolean inXLS = false;
	private boolean inResponseHeader = false;
	private boolean inResponse = false;
	private boolean inDetermineRouteResponse = false;
	private boolean inRouteSummary = false;
	private boolean inTotalTime = false;
	private boolean inTotalDistance = false;
	private boolean inBoundingBox = false;
	private boolean inPos = false;
	private boolean inRouteGeometry = false;
	private boolean inRouteHandle = false;
	private boolean inLineString = false;
	private boolean inRouteInstructionsList = false;
	private boolean inRouteInstruction = false;
	private boolean inInstruction = false;
	private boolean inDistance = false;
	private boolean inRouteInstructionGeometry = false;

	private RouteInstruction mTmpRouteInstruction;

	// ===========================================================
	// Constructors
	// ===========================================================


	public OpenRouteServiceRSParser() {
	}

	// ===========================================================
	// Getter & Setter
	// ===========================================================

	public ArrayList<Error> getErrors(){
		return this.mErrors;
	}

	public Route getRoute() throws ORSException{
		if(this.mErrors != null && this.mErrors.size() > 0) {
			throw new ORSException(this.mErrors);
		}

		return this.mRoute;
	}

	// ====================================
	// Methods from Superclasses
	// ====================================

	@Override
	public void startDocument() throws SAXException {
		this.mRoute = new Route();
		this.mRoute.setRouteInstructions(new ArrayList<RouteInstruction>());
		this.mPolyline = new ArrayList<GeoPoint>();
		super.startDocument();
	}

	@Override
	public void startElement(final String uri, final String localName, final String name, final Attributes attributes) throws SAXException {
		if(localName.equals("Error") || name.equals("Error")){
			final String errorCode = attributes.getValue("", "errorCode");
			final String severity = attributes.getValue("", "severity");
			final String locationPath = attributes.getValue("", "locationPath");
			final String message = attributes.getValue("", "message");
			this.mErrors.add(new Error(errorCode, severity, locationPath, message));
		}

		this.sb.setLength(0);

		if(localName.equals("XLS")){
			this.inXLS = true;
		} else if(localName.equals("ResponseHeader")){
			this.inResponseHeader = true;
		} else if(localName.equals("Response")){
			this.inResponse = true;
		} else if(localName.equals("DetermineRouteResponse")){
			this.inDetermineRouteResponse = true;
		} else if(localName.equals("RouteSummary")){
			this.inRouteSummary = true;
		} else if(localName.equals("TotalTime")){
			this.inTotalTime = true;
		} else if(localName.equals("TotalDistance")){
			this.inTotalDistance = true;
			final String uom = attributes.getValue("", "uom");

			float factor = 0;
			if(uom != null){
				if(uom.equals("M")){
					factor = 1;
				}else if(uom.equals("KM")){
					factor = 1000;
				}
			}
			this.mRoute.setDistanceMeters((int)(factor * Float.parseFloat(attributes.getValue("", "value"))));
		} else if(localName.equals("BoundingBox")){
			this.inBoundingBox = true;
		} else if(localName.equals("RouteHandle")){
			this.mRoute.setRouteHandleID(Long.parseLong(attributes.getValue("", "routeID")));
			this.inRouteHandle = true;
		} else if(localName.equals("pos")){
			this.inPos = true;
		} else if(localName.equals("RouteGeometry")){
			this.inRouteGeometry = true;
		} else if(localName.equals("LineString")){
			this.inLineString = true;
		} else if(localName.equals("RouteInstructionsList")){
			this.inRouteInstructionsList = true;
		} else if(localName.equals("RouteInstruction")){
			this.inRouteInstruction = true;
			this.mTmpRouteInstruction = new RouteInstruction();
			this.mRoute.getRouteInstructions().add(this.mTmpRouteInstruction);
			this.mTmpRouteInstruction.setDurationSeconds(TimeUtils.durationTimeString(attributes.getValue("", "duration")));
		} else if(localName.equals("Instruction")){
			this.inInstruction = true;
		} else if(localName.equals("distance")){
			this.inDistance = true;
			final String uom = attributes.getValue("", "uom");

			float factor = 0;
			if(uom != null){
				if(uom.equals("M")){
					factor = 1;
				}else if(uom.equals("KM")){
					factor = 1000;
				}
			}

			this.mTmpRouteInstruction.setLengthMeters((int)(factor * Float.parseFloat(attributes.getValue("", "value"))));
		} else if(localName.equals("RouteInstructionGeometry")){
			this.inRouteInstructionGeometry = true;
		} else {
			Log.w(DEBUGTAG, "Unexpected tag: '" + name + "'");
		}
		super.startElement(uri, localName, name, attributes);
	}

	protected StringBuilder sb = new StringBuilder();
	private int mLastFirstMotherPolylineIndex = 0;

	@Override
	public void characters(final char[] chars, final int start, final int length) throws SAXException {
		this.sb.append(chars, start, length);
		super.characters(chars, start, length);
	}

	@Override
	public void endElement(final String uri, final String localName, final String name) throws SAXException {
		if(localName.equals("XLS")){
			this.inXLS = false;
		} else if(localName.equals("ResponseHeader")){
			this.inResponseHeader = false;
		} else if(localName.equals("Response")){
			this.inResponse = false;
		} else if(localName.equals("DetermineRouteResponse")){
			this.inDetermineRouteResponse = false;
		} else if(localName.equals("RouteSummary")){
			this.inRouteSummary = false;
		} else if(localName.equals("TotalTime")){
			this.inTotalTime = false;
			this.mRoute.setDurationSeconds(TimeUtils.durationTimeString(this.sb.toString()));
		} else if(localName.equals("TotalDistance")){
			this.inTotalDistance = false;
		} else if(localName.equals("BoundingBox")){
			this.inBoundingBox = false;
		} else if(localName.equals("RouteHandle")){
			this.inRouteHandle = false;
		} else if(localName.equals("pos")){
			this.inPos = false;
			final GeoPoint gp = GeoPoint.fromInvertedDoubleString(this.sb.toString(), ' ');
			if(this.inRouteGeometry){
				this.mPolyline.add(gp);
			} else if(this.inRouteInstructionGeometry){
				this.mTmpRouteInstruction.getPartialPolyLine().add(gp);
				// If this was the first element, we will determine its position in the OverallPolyline
				if(this.mTmpRouteInstruction.getPartialPolyLine().size() == 1) {
					this.mLastFirstMotherPolylineIndex = this.mRoute.findInPolyLine(gp, this.mLastFirstMotherPolylineIndex);
					this.mTmpRouteInstruction.setFirstMotherPolylineIndex(this.mLastFirstMotherPolylineIndex);
				}
			} else if(this.inBoundingBox){
				if(this.tmp == null){ // First GeoPoint
					this.tmp = gp;
				}else{ // Second one
					final int mFirstLatE6 = this.tmp.getLatitudeE6();
					final int mFirstLonE6 = this.tmp.getLongitudeE6();
					this.tmp = gp;
					final int mSecondLatE6 = this.tmp.getLatitudeE6();
					final int mSecondLonE6 = this.tmp.getLongitudeE6();
					this.mRoute.setBoundingBoxE6(new BoundingBoxE6(Math.max(mFirstLatE6, mSecondLatE6),
							Math.max(mFirstLonE6, mSecondLonE6),
							Math.min(mFirstLatE6, mSecondLatE6),
							Math.min(mFirstLonE6, mSecondLonE6)));
				}
			}
		} else if(localName.equals("RouteGeometry")){
			this.inRouteGeometry = false;
			this.mRoute.setPolyLine(this.mPolyline);
		} else if(localName.equals("LineString")){
			this.inLineString = false;
		} else if(localName.equals("RouteInstructionsList")){
			this.inRouteInstructionsList = false;
		} else if(localName.equals("RouteInstruction")){
			this.inRouteInstruction = false;
		} else if(localName.equals("Instruction")){
			this.inInstruction = false;
			if(this.mTmpRouteInstruction.getDescriptionHtml() == null) {
				this.mTmpRouteInstruction.setDescriptionHtml(this.sb.toString());
			} else {
				this.mTmpRouteInstruction.setDescriptionHtml(this.mTmpRouteInstruction.getDescriptionHtml() + this.sb.toString());
			}
		} else if(localName.equals("distance")){
			this.inDistance = false;
		} else if(localName.equals("RouteInstructionGeometry")){
			this.inRouteInstructionGeometry = false;
		} else {
			Log.w(DEBUGTAG, "Unexpected end-tag: '" + name + "'");
		}

		// Reset the stringbuffer
		this.sb.setLength(0);

		super.endElement(uri, localName, name);
	}

	@Override
	public void endDocument() throws SAXException {
		if(this.mErrors == null || this.mErrors.size() == 0){
			this.mRoute.setStart(this.mPolyline.get(0));
			this.mRoute.setDestination(this.mPolyline.get(this.mPolyline.size() - 1));

			this.mRoute.setStartInstruction(this.mRoute.getRouteInstructions().remove(0));

			// Modify the arrival-instruction that is just shows
			final RouteInstruction last = this.mRoute.getRouteInstructions().get(this.mRoute.getRouteInstructions().size() - 1);
			last.setFirstMotherPolylineIndex(this.mPolyline.size() - 1);
		}
		super.endDocument();
	}

}
